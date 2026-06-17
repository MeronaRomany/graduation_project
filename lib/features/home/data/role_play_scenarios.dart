import 'models/role_play_scenario.dart';

final List<RolePlayScenario> rolePlayScenarios = [
  // ═══════════════════════════════════════════
  // A1.1 - Absolute Beginner
  // ═══════════════════════════════════════════
  const RolePlayScenario(
    id: 'greetings',
    title: 'Saying Hello',
    description: 'Learn to greet people and introduce yourself',
    emoji: '👋',
    systemPrompt: '''You are a friendly person at a community center. Your role is to greet newcomers, exchange basic introductions, and have very simple conversations. Use extremely simple language with short sentences.''',
    starterMessage: "Hello! My name is Sarah. What is your name?",
    difficulty: DifficultyLevel.beginner,
    category: ScenarioCategory.social,
    cefrLevel: CefrLevel.a11,
    suggestedVocabulary: ['hello', 'hi', 'name', 'nice', 'meet', 'from'],
    commonPhrases: [
      "Hello, my name is...",
      "Nice to meet you.",
      "I am from...",
    ],
    writingTasks: {
      DifficultyLevel.beginner: [
        "Write a short introduction: My name is [Name], and I am from [Country].",
        "Write a greeting to a new friend."
      ],
    },
  ),

  const RolePlayScenario(
    id: 'ordering_food',
    title: 'Ordering Food',
    description: 'Order simple food and drinks at a cafe',
    emoji: '🍽️',
    systemPrompt: '''You are a friendly cafe worker. Help customers order simple food and drinks.''',
    starterMessage: "Welcome! What would you like to order?",
    difficulty: DifficultyLevel.beginner,
    category: ScenarioCategory.dailyLife,
    cefrLevel: CefrLevel.a11,
    suggestedVocabulary: ['coffee', 'tea', 'water', 'juice'],
    commonPhrases: [
      "I would like...",
      "Can I have...",
    ],
    writingTasks: {
      DifficultyLevel.beginner: [
        "Write a simple restaurant review: 'The food is good. I like the coffee.'",
        "Write a message to order a pizza."
      ],
      DifficultyLevel.intermediate: [
        "Describe your favorite dining experience in a short paragraph.",
        "Write a review of a restaurant you visited recently."
      ],
    },
  ),

  const RolePlayScenario(
    id: 'airport',
    title: 'At the Airport',
    description: 'Check-in and navigate airport procedures',
    emoji: '✈️',
    systemPrompt: 'You are an airport check-in agent.',
    starterMessage: "Hello, may I see your passport and ticket, please?",
    difficulty: DifficultyLevel.intermediate,
    category: ScenarioCategory.travel,
    cefrLevel: CefrLevel.b11,
    writingTasks: {
      DifficultyLevel.beginner: ["Write your name and destination on a luggage tag."],
      DifficultyLevel.intermediate: ["Describe your last trip or write about airport procedures."],
      DifficultyLevel.advanced: ["Write a formal complaint about a delayed flight."],
    },
  ),

  const RolePlayScenario(
    id: 'job_interview',
    title: 'Job Interview',
    description: 'Practice answering common interview questions',
    emoji: '💼',
    systemPrompt: 'You are an HR Manager conducting an interview.',
    starterMessage: "Welcome. To start, could you tell me a bit about yourself?",
    difficulty: DifficultyLevel.advanced,
    category: ScenarioCategory.business,
    cefrLevel: CefrLevel.b21,
    writingTasks: {
      DifficultyLevel.intermediate: ["Write a self-introduction paragraph for a job."],
      DifficultyLevel.advanced: ["Write a cover letter paragraph for a position you're interested in."],
    },
  ),
];
