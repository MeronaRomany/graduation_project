import os
import torch
import argparse
import logging
import json
from datasets import load_dataset, Audio
from dataclasses import dataclass
from typing import Any, Dict, List, Union
from transformers import (
    WhisperProcessor,
    WhisperForConditionalGeneration,
    Seq2SeqTrainingArguments,
    Seq2SeqTrainer,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("whisper_training.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

try:
    import evaluate
    HAS_EVALUATE = True
except ImportError:
    HAS_EVALUATE = False

@dataclass
class DataCollatorSpeechSeq2SeqWithPadding:
    processor: Any

    def __call__(self, features: List[Dict[str, Union[List[int], torch.Tensor]]]) -> Dict[str, torch.Tensor]:
        input_features = [{"input_features": f["input_features"]} for f in features]
        batch = self.processor.feature_extractor.pad(input_features, return_tensors="pt")

        label_features = [{"input_ids": f["labels"]} for f in features]
        labels_batch = self.processor.tokenizer.pad(label_features, return_tensors="pt")
        
        labels = labels_batch["input_ids"].masked_fill(labels_batch.attention_mask.ne(1), -100)

        # Remove BOS token if present
        if (labels[:, 0] == self.processor.tokenizer.bos_token_id).all():
            labels = labels[:, 1:]

        batch["labels"] = labels
        return batch

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_id", type=str, default="openai/whisper-tiny")
    parser.add_argument("--output_dir", type=str, default="./whisper-tiny-ljspeech")
    parser.add_argument("--max_steps", type=int, default=50)
    parser.add_argument("--batch_size", type=int, default=2)
    args, _ = parser.parse_known_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    logger.info(f"Using device: {device}")
    
    # Load dataset
    logger.info("Loading LJSpeech dataset...")
    try:
        dataset = load_dataset("keithito/lj_speech", revision="refs/convert/parquet", split="train")
    except Exception:
        logger.warning("Failed parquet load, falling back to standard load...")
        dataset = load_dataset("keithito/lj_speech", split="train", trust_remote_code=True)

    dataset = dataset.train_test_split(test_size=0.01, seed=42)
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))
    
    # Load processor and model
    logger.info(f"Loading Whisper processor and model: {args.model_id}...")
    processor = WhisperProcessor.from_pretrained(args.model_id, language="English", task="transcribe")
    model = WhisperForConditionalGeneration.from_pretrained(args.model_id, return_dict=False, use_cache=False)



    # Clear specific generation config parameters
    model.generation_config.forced_decoder_ids = None
    model.generation_config.suppress_tokens = []
    for param in ["forced_decoder_ids", "suppress_tokens", "max_length", "begin_suppress_tokens", 
                  "num_beams", "do_sample", "temperature", "top_k", "top_p", "repetition_penalty",
                  "length_penalty", "no_repeat_ngram_size", "bad_words_ids"]:
        if hasattr(model.config, param):
            delattr(model.config, param)
            
    model.to(device)

    def prepare_dataset(batch):
        audio = batch["audio"]
        return {
            "input_features": processor.feature_extractor(audio["array"], sampling_rate=audio["sampling_rate"]).input_features[0],
            "labels": processor.tokenizer(batch.get("normalized_text", batch["text"])).input_ids
        }

    logger.info("Preprocessing datasets...")
    encoded_dataset = dataset.map(prepare_dataset, remove_columns=dataset["train"].column_names)

    # Setup Metrics
    compute_metrics_fn = None
    if HAS_EVALUATE:
        logger.info("Evaluate library found. Setting up Word Error Rate (WER) calculation...")
        wer_metric = evaluate.load("wer")
        
        def compute_metrics(pred):
            pred_ids = pred.predictions
            label_ids = pred.label_ids
            label_ids[label_ids == -100] = processor.tokenizer.pad_token_id
            
            pred_str = processor.tokenizer.batch_decode(pred_ids, skip_special_tokens=True)
            label_str = processor.tokenizer.batch_decode(label_ids, skip_special_tokens=True)
            return {"wer": 100 * wer_metric.compute(predictions=pred_str, references=label_str)}
            
        compute_metrics_fn = compute_metrics
    else:
        logger.warning("Evaluate/jiwer missing. Skipping WER evaluation metrics.")

    # Train
    training_args = Seq2SeqTrainingArguments(
        output_dir=args.output_dir,
        per_device_train_batch_size=args.batch_size,
        max_steps=args.max_steps,
        eval_strategy="steps",
        save_steps=args.max_steps,
        eval_steps=min(10, args.max_steps),
        logging_steps=2,
        report_to=["none"],
        predict_with_generate=HAS_EVALUATE,
        generation_max_length=225,
        dataloader_drop_last=True,
    )

    trainer = Seq2SeqTrainer(
        model=model,
        args=training_args,
        train_dataset=encoded_dataset["train"],
        eval_dataset=encoded_dataset["test"],
        data_collator=DataCollatorSpeechSeq2SeqWithPadding(processor=processor),
        compute_metrics=compute_metrics_fn,
    )

    logger.info("Starting training...")
    trainer.train()
    logger.info("Training finished!")

    # Save Models
    model.save_pretrained(args.output_dir)
    processor.save_pretrained(args.output_dir)
    logger.info(f"Model and processor saved to {args.output_dir}")

    # Save Metrics Log
    metrics_path = os.path.join(args.output_dir, "training_metrics.json")
    os.makedirs(args.output_dir, exist_ok=True)
    with open(metrics_path, "w") as f:
        json.dump(trainer.state.log_history, f, indent=4)
    logger.info(f"Training metrics (loss, WER, steps) saved to {metrics_path}")

if __name__ == "__main__":
    main()