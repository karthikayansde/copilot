
  class Endpoints {
    static String get baseUrl => 'http://apihub.pilogcloud.com:6735';
    static String get insightBaseUrl => 'http://apihub.pilogcloud.com:6670';

    static String get login => '/auth/login';
    static String get signUp => '/auth/register';
    static String get ask => '/ask';
    static String get sessions => '/chat/sessions?username=';

    static String get updateSessionTitle => '/session/rename';
    static String get deleteSession => '/session/delete';
    static String get saveFeedback => '/save-feedback';
    static String get getSessionChats => '/chat/session/';
    static String get dataInsights => '/data_insights/';

  }