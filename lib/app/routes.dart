/// Route paths in one place, so no path string is repeated in widgets.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const signUpPhone = '/sign-up/phone';
  static const signUpVerify = '/sign-up/verify';
  static const signUpProfile = '/sign-up/profile';
  static const home = '/';
  static const sendMoney = '/send';
  static const settings = '/settings';
  static const transactionDetailPattern = '/transactions/:id';

  static String transactionDetail(String id) => '/transactions/$id';

  /// The screens a signed-out user may see.
  static bool isAuthFlow(String location) =>
      location == welcome ||
      location == signIn ||
      location == signUp ||
      location.startsWith('$signUp/');
}
