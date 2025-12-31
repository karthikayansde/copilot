
class Endpoints {
  static String get baseUrl => 'https://cart-mate-api.onrender.com';
  // static String get baseUrl => 'http://localhost:3000';

  // auth
  static String get login => '/auth/login';
  static String get update => '/auth/update';
  static String get delete => '/auth/delete-account/';
  static String get resendOtp => '/auth/resend-otp';
  static String get signUp => '/auth/sign-up';
  static String get verifyOtp => '/auth/verify-otp';
  static String get forgotPassword => '/auth/forgot-password/';
  static String get changePassword => '/auth/change-password';

  static String get feedback => '/auth/feed-back';
  // mate
  static String get addMate => '/mates/add';
  static String get getMates => '/mates/list/';
  static String get deleteMate => '/mates/delete';
  // UOM list
  static String get getUom => '/uom/get-uom-list';
  // menu list
  static String get addList => '/item-list/add';
  // menu item
  static String get addItem => '/item/add';
  static String get editItem => '/item/update';
  static String get getItems => '/item/getItems/';
  static String get updateStatus => '/item/status-update/';
  static String get deleteItem => '/item/delete-item';

  // image generation
  static String getImage(String name) {
    String newString = name.replaceAll(' ', '+');
    return 'https://pixabay.com/api/?key=51790301-5eacac95696c6077e840e2b99&q=$newString&image_type=photo&safesearch=false&per_page=11';
  }
}