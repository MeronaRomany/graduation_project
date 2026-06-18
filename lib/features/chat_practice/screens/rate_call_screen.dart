import 'package:flutter/material.dart';
import 'package:graduation_app/core/utils/app_colors.dart';

class RateCallScreen extends StatefulWidget {
  final String peerName;
  const RateCallScreen({super.key, required this.peerName});

  @override
  State<RateCallScreen> createState() => _RateCallScreenState();
}

class _RateCallScreenState extends State<RateCallScreen> {
  int _connectionRating = 0;
  int _peerRating = 0;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _evaluationController = TextEditingController();

  Widget _buildStarRating(int rating, ValueChanged<int> onRatingChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppColors.primaryColor,
            size: 32,
          ),
          onPressed: () => onRatingChanged(index + 1),
        );
      }),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _evaluationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF919CEA),
      appBar: AppBar(
        title: const Text('Rate Call Session',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How was your connection?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
                child: _buildStarRating(_connectionRating,
                    (val) => setState(() => _connectionRating = val))),
            const SizedBox(height: 32),
            Text(
              'How was your experience with ${widget.peerName}?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
                child: _buildStarRating(
                    _peerRating, (val) => setState(() => _peerRating = val))),
            const SizedBox(height: 32),
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Conversation Topic',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., Job interview preparation',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _evaluationController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Linguistic Evaluation',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText:
                    'Notes on speaking fluency, listening comprehension, pronunciation difficulties...',
                hintStyle: const TextStyle(color: Colors.white38),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Submit review
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Send Review',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // Report user logic
              },
              icon: const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent),
              label: const Text('Report User',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
