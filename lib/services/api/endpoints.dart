
class Endpoints {
  // static String get baseUrl => 'http://apihub.pilogcloud.com:6735';
  static String get insightBaseUrl => 'http://apihub.pilogcloud.com:6730';
  static String get askQuestionBaseUrl => 'http://apihub.pilogcloud.com:6732';
  static String get chatWithDataMobBaseUrl => 'http://apihub.pilogcloud.com:6730';
  static String get chatWithDataBaseUrl => 'http://apihub.pilogcloud.com:6730';
  // static String get registerBaseUrl => 'https://mirai.pilogcloud.com:6734';
  static String get registerBaseUrl => 'https://mirai.pilogcloud.com/login';
  static String get loginBaseUrl => 'http://apihub.pilogcloud.com:6727';

  // static String get baseUrl => 'https://mirai.pilogcloud.com:6735';
  static String get baseUrl => 'https://mirai.pilogcloud.com/api';
  // static String get chatWithDataMobBaseUrl => 'https://mirai.pilogcloud.com:6735';
  static String get login => '$registerBaseUrl/auth/login';
  static String get resendActivation => '$registerBaseUrl/auth/resend-activation';
  static String get forgotPassword => '$registerBaseUrl/auth/forgot-password';
  static String get signUp => '$registerBaseUrl/auth/register';
  static String get ask => '$baseUrl/ask?role=viewer';
  static String get sessions => '$baseUrl/chat/sessions?username=';

  static String get updateSessionTitle => '$baseUrl/session/rename';
  static String get deleteSession => '$baseUrl/session/delete';
  static String get saveFeedback => '$baseUrl/save-feedback';
  static String get getSessionChats => '$baseUrl/chat/session/';
  static String get dataInsights => '$insightBaseUrl/chat_with_data_json_exec';
  static String get askQuestion => '$askQuestionBaseUrl/ask_question';
  static String get chatWithDataMob => '$chatWithDataMobBaseUrl/suggested_questions';
  static String get chatWithData => '$chatWithDataBaseUrl/chat_with_data';
  static String get creditsUsage => '$baseUrl/credits/usage?username=';
  static String get exportChats => '$baseUrl/export-chats/';
  static String get knowledgeSources => 'http://apihub.pilogcloud.com:6735/api/knowledge-sources?role=admin&user_name=Rahul';
}