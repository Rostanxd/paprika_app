class FieldTypeValidators {
  static Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\'
      r'[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+'
      r'[a-zA-Z]{2,}))$';
  static RegExp regex = new RegExp(pattern);

  static bool isEmail(String email) {
    if (regex.hasMatch(email)) return true;
    return false;
  }

  static bool stringIsNumeric(String s) {
    if (s == null) {
      return false;
    }
    // ignore: deprecated_member_use
    return double.parse(s, (e) => null) != null;
  }
}
