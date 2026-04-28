/// App secrets and API keys
library;

/// Set via --dart-define=OPENAI_API_KEY=sk-... at build time
const String openAiKey = String.fromEnvironment('OPENAI_API_KEY');
