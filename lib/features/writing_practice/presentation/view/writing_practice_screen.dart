import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../home/data/models/role_play_scenario.dart';
import '../cubit/writing_practice_cubit.dart';
import '../cubit/writing_practice_state.dart';
import 'writing_analysis_screen.dart';

class WritingPracticeScreen extends StatefulWidget {
  static const String routeName = '/writing-practice';

  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Writing Practice'),
        centerTitle: true,
      ),
      body: BlocConsumer<WritingPracticeCubit, WritingPracticeState>(
        listener: (context, state) {
          if (state is WritingAnalysisSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WritingAnalysisScreen(analysis: state.analysis),
              ),
            );
          } else if (state is WritingPracticeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is WritingPracticeInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WritingPracticeLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI is analyzing your writing...'),
                ],
              ),
            );
          }

          if (state is WritingPracticeLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WritingPracticeLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a Scenario', style: AppTextStyles.bold19),
          const SizedBox(height: 12),
          _buildScenarioDropdown(context, state),
          if (state.selectedScenario != null) ...[
            const SizedBox(height: 24),
            _buildTaskCard(context, state),
            const SizedBox(height: 24),
            _buildWritingInput(context),
            const SizedBox(height: 24),
            _buildAnalyzeButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildScenarioDropdown(BuildContext context, WritingPracticeLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RolePlayScenario>(
          isExpanded: true,
          hint: const Text('Choose a scenario'),
          value: state.selectedScenario,
          items: state.scenarios.map((scenario) {
            return DropdownMenuItem(
              value: scenario,
              child: Row(
                children: [
                  Text(scenario.emoji),
                  const SizedBox(width: 12),
                  Text(scenario.title),
                ],
              ),
            );
          }).toList(),
          onChanged: (scenario) {
            if (scenario != null) {
              context.read<WritingPracticeCubit>().selectScenario(scenario);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WritingPracticeLoaded state) {
    final scenario = state.selectedScenario!;
    final taskText = 'Write about your experience in the following scenario: ${scenario.title}. Use the suggested vocabulary if possible.';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scenario.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scenario.categoryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: scenario.categoryColor),
              const SizedBox(width: 8),
              Text('Writing Task', style: AppTextStyles.bold16.copyWith(color: scenario.categoryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            taskText,
            style: AppTextStyles.medium15,
          ),
        ],
      ),
    );
  }

  Widget _buildWritingInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: 'Start writing here...',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          onChanged: (text) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          '${_controller.text.length} characters',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    final bool canAnalyze = _controller.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canAnalyze 
            ? () => context.read<WritingPracticeCubit>().analyzeWriting(_controller.text)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Analyze Writing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
