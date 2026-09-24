/// Route paths in one place, so no path string is repeated in widgets.
abstract final class AppRoutes {
  static const signIn = '/sign-in';
  static const home = '/';
  static const sendMoney = '/send';
  static const settings = '/settings';
  static const transactionDetailPattern = '/transactions/:id';

  static String transactionDetail(String id) => '/transactions/$id';
}
