import os
import torch
import argparse
import numpy as np
from datasets import load_dataset, Audio
from dataclasses import dataclass
from typing import Any, Dict, List
from transformers import (
    SpeechT5Processor,
    SpeechT5ForTextToSpeech,
    Seq2SeqTrainingArguments,
    Seq2SeqTrainer,
)

@dataclass
class TTSDataCollatorWithPadding:
    processor: Any
    reduction_factor: int = 2

    def __call__(self, features: List[Dict[str, Any]]) -> Dict[str, torch.Tensor]:
        input_ids = [{"input_ids": f["input_ids"]} for f in features]
        label_features = [{"input_values": f["labels"]} for f in features]

        batch = self.processor.pad(
            input_ids=input_ids, labels=label_features, return_tensors="pt"
        )

        # Replace padding with -100 to ignore loss correctly
        batch["labels"] = batch["labels"].masked_fill(
            batch.decoder_attention_mask.unsqueeze(-1).ne(1), -100
        )
        batch.pop("decoder_attention_mask", None)

        # Apply reduction factor to labels
        if self.reduction_factor > 1:
            seq_len = batch["labels"].shape[1]
            batch["labels"] = batch["labels"][:, : seq_len - (seq_len % self.reduction_factor)]

        batch["speaker_embeddings"] = torch.stack([torch.tensor(f["speaker_embeddings"]) for f in features])
        return batch

def get_speaker_embedding(dataset, device):
    """Loads or generates a speaker embedding."""
    emb_file = "ljspeech_speaker_embedding.npy"
    if os.path.exists(emb_file):
        return np.load(emb_file)
        
    try:
        from speechbrain.inference.speaker import EncoderClassifier
        classifier = EncoderClassifier.from_hparams(source="speechbrain/spkrec-xvect-voxceleb", run_opts={"device": device})
        embeddings = [
            classifier.encode_batch(torch.tensor(dataset[i]["audio"]["array"]).unsqueeze(0).to(device)).squeeze().cpu().numpy()
            for i in range(min(5, len(dataset)))
        ]
        embedding = np.mean(embeddings, axis=0)
    except ImportError:
        print("WARNING: SpeechBrain missing. Generating dummy embedding. Run `pip install speechbrain` for real embeddings.")
        dummy = np.random.randn(512)
        embedding = dummy / np.linalg.norm(dummy)

    np.save(emb_file, embedding)
    return embedding

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_id", type=str, default="microsoft/speecht5_tts")
    parser.add_argument("--output_dir", type=str, default="./speecht5-tts-ljspeech")
    parser.add_argument("--max_steps", type=int, default=50)
    parser.add_argument("--batch_size", type=int, default=2)
    args, _ = parser.parse_known_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    
    # Load and prep dataset
    dataset = load_dataset("keithito/lj_speech", revision="refs/convert/parquet", split="train")
    dataset = dataset.train_test_split(test_size=0.01, seed=42)
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))

    speaker_emb = get_speaker_embedding(dataset["train"], device).tolist()
    processor = SpeechT5Processor.from_pretrained(args.model_id)
    model = SpeechT5ForTextToSpeech.from_pretrained(args.model_id, return_dict=False, use_cache=False).to(device)



    def prepare_dataset(batch):
        audio = batch["audio"]
        processed = processor(
            text=batch.get("normalized_text", batch["text"]),
            audio_target=audio["array"],
            sampling_rate=audio["sampling_rate"],
            return_attention_mask=False
        )
        return {
            "input_ids": processed["input_ids"],
            "labels": processed["labels"][0],
            "speaker_embeddings": speaker_emb
        }

    encoded_dataset = dataset.map(prepare_dataset, remove_columns=dataset["train"].column_names)

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
        dataloader_drop_last=True,
    )


    trainer = Seq2SeqTrainer(
        model=model,
        args=training_args,
        train_dataset=encoded_dataset["train"],
        eval_dataset=encoded_dataset["test"],
        data_collator=TTSDataCollatorWithPadding(processor=processor),
    )

    trainer.train()

    # Save
    model.save_pretrained(args.output_dir)
    processor.save_pretrained(args.output_dir)
    print(f"Model saved to {args.output_dir}")

if __name__ == "__main__":
    main()