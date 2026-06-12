class Tokenizer {
  final Map<String, int> vocab;

  Tokenizer(this.vocab);

  List<int> encode(String text) {
    return text
        .toLowerCase()
        .split('')
        .map((c) => vocab[c] ?? 0)
        .toList();
  }
}