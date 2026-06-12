import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'onnx_service.dart';

class WhisperOnnxService extends OnnxService {
  WhisperOnnxService(super.path);
  static const int _sampleRate = 16000;
  static const int _nMels = 80;
  static const int _nFFT = 400;
  static const int _hopLength = 160;
  static const int _chunkSamples = 30 * _sampleRate;
  static const int _nFrames = 3000;

  List<List<double>>? _cachedFilterbank;

  Future<String> transcribe(Float32List audio) async {
    if (session == null) await init();
    if (audio.isEmpty) return '';

    try {
      print("INPUT NAMES = ${session!.inputNames}");
      print("OUTPUT NAMES = ${session!.outputNames}");

      // 1. Pad or trim
      final paddedAudio = _padOrTrimAudio(audio, _chunkSamples);

      // 2. Mel spectrogram
      final mel = _computeMelSpectrogram(paddedAudio);

      // 3. Build tensor — Whisper يحتاج float32 ✅
      final inputOrt = await OrtValue.fromList(
        mel, // Float32List مباشرة بدل .toList()
        [1, _nMels, _nFrames],
      );

      // 4. اعرف input name الصح من الموديل
      final inputNames = session!.inputNames;
      final inputKey = inputNames.isNotEmpty ? inputNames[0] : 'input_features';

      final inputs = {inputKey: inputOrt};
      final outputs = await session!.run(inputs);

      // 5. Decode
      final result = outputs.values.first;
      final raw = await result.asList();

      return _decodeTokens(raw);
    } catch (e, s) {
      print("WHISPER ERROR: $e");
      print(s);
      return 'Transcription error: $e';
    }
  }

  // ─── Audio padding ────────────────────────────────────────────────────────

  Float32List _padOrTrimAudio(Float32List audio, int targetLength) {
    if (audio.length == targetLength) return audio;
    final out = Float32List(targetLength);
    out.setRange(0, math.min(audio.length, targetLength), audio);
    return out;
  }


  Float32List _computeMelSpectrogram(Float32List audio) {
    final mel = Float32List(_nMels * _nFrames);

    final window = Float32List(_nFFT);
    for (int i = 0; i < _nFFT; i++) {
      window[i] = 0.5 * (1.0 - math.cos(2 * math.pi * i / (_nFFT - 1)));
    }

    _cachedFilterbank ??= _melFilterbank(_nMels, _nFFT, _sampleRate);
    final filterbank = _cachedFilterbank!;

    for (int frame = 0; frame < _nFrames; frame++) {
      final start = frame * _hopLength;

      // Windowed frame
      final windowed = Float32List(_nFFT);
      for (int i = 0; i < _nFFT; i++) {
        final idx = start + i;
        windowed[i] = (idx < audio.length ? audio[idx] : 0.0) * window[i];
      }

      final power = _fftPowerSpectrum(windowed);

      // Mel filterbank + log
      for (int m = 0; m < _nMels; m++) {
        double energy = 0.0;
        final fb = filterbank[m];
        for (int k = 0; k < fb.length; k++) {
          energy += fb[k] * power[k];
        }
        mel[m * _nFrames + frame] =
            math.log(energy < 1e-10 ? 1e-10 : energy) / math.ln10;
      }
    }

    // Normalize: clamp to max-8, scale to [-1, 1]
    double maxVal = -double.infinity;
    for (final v in mel) {
      if (v > maxVal) maxVal = v;
    }
    for (int i = 0; i < mel.length; i++) {
      mel[i] = (math.max(mel[i], maxVal - 8.0) + 4.0) / 4.0;
    }

    return mel;
  }


  /// Returns power spectrum [nFFT/2 + 1] باستخدام FFT O(n log n)
  List<double> _fftPowerSpectrum(Float32List frame) {
    final n = frame.length;
    // Zero-pad to next power of 2 لو مش power of 2
    final fftSize = _nextPow2(n);

    final re = List<double>.filled(fftSize, 0.0);
    final im = List<double>.filled(fftSize, 0.0);
    for (int i = 0; i < n; i++) re[i] = frame[i];

    _fft(re, im, fftSize);

    final half = n ~/ 2 + 1;
    return List<double>.generate(
      half,
          (k) => re[k] * re[k] + im[k] * im[k],
    );
  }


  void _fft(List<double> re, List<double> im, int n) {
    // Bit-reversal permutation
    int j = 0;
    for (int i = 1; i < n; i++) {
      int bit = n >> 1;
      for (; j & bit != 0; bit >>= 1) j ^= bit;
      j ^= bit;
      if (i < j) {
        final tr = re[i]; re[i] = re[j]; re[j] = tr;
        final ti = im[i]; im[i] = im[j]; im[j] = ti;
      }
    }

    // FFT butterfly
    for (int len = 2; len <= n; len <<= 1) {
      final ang = -2 * math.pi / len;
      final wRe = math.cos(ang);
      final wIm = math.sin(ang);
      for (int i = 0; i < n; i += len) {
        double curRe = 1.0, curIm = 0.0;
        for (int k = 0; k < len ~/ 2; k++) {
          final uRe = re[i + k];
          final uIm = im[i + k];
          final vRe = re[i + k + len ~/ 2] * curRe - im[i + k + len ~/ 2] * curIm;
          final vIm = re[i + k + len ~/ 2] * curIm + im[i + k + len ~/ 2] * curRe;
          re[i + k] = uRe + vRe;
          im[i + k] = uIm + vIm;
          re[i + k + len ~/ 2] = uRe - vRe;
          im[i + k + len ~/ 2] = uIm - vIm;
          final newCurRe = curRe * wRe - curIm * wIm;
          curIm = curRe * wIm + curIm * wRe;
          curRe = newCurRe;
        }
      }
    }
  }

  int _nextPow2(int n) {
    int p = 1;
    while (p < n) p <<= 1;
    return p;
  }

  // ─── Mel Filterbank ───────────────────────────────────────────────────────

  List<List<double>> _melFilterbank(int nMels, int nFFT, int sampleRate) {
    final half = nFFT ~/ 2 + 1;
    const fMin = 0.0;
    final fMax = sampleRate / 2.0;

    double hzToMel(double hz) => 2595.0 * math.log(1 + hz / 700.0) / math.ln10;
    double melToHz(double mel) => 700.0 * (math.pow(10, mel / 2595.0) - 1);

    final melMin = hzToMel(fMin);
    final melMax = hzToMel(fMax);

    final melPoints = List<double>.generate(
      nMels + 2,
          (i) => melMin + i * (melMax - melMin) / (nMels + 1),
    );

    final bins = melPoints
        .map((m) => ((melToHz(m) / sampleRate) * nFFT).floor().clamp(0, half - 1))
        .toList();

    return List<List<double>>.generate(nMels, (m) {
      final row = List<double>.filled(half, 0.0);
      for (int k = bins[m]; k < bins[m + 1] && k < half; k++) {
        final denom = bins[m + 1] - bins[m];
        row[k] = denom == 0 ? 0.0 : (k - bins[m]) / denom;
      }
      for (int k = bins[m + 1]; k < bins[m + 2] && k < half; k++) {
        final denom = bins[m + 2] - bins[m + 1];
        row[k] = denom == 0 ? 0.0 : (bins[m + 2] - k) / denom;
      }
      return row;
    });
  }


  String _decodeTokens(List<dynamic> tokens) {
    if (tokens.isEmpty) return '';

    final ids = tokens
        .map((e) => (e as num).toInt())
        .where((id) => id > 3 && id < 50256)
        .toList();

    if (ids.isEmpty) return '';

    return ids
        .where((id) => id >= 32 && id < 127)
        .map((id) => String.fromCharCode(id))
        .join();
  }
}
