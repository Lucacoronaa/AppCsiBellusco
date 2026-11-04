const minPasswordLength = 6;

final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String email) => _emailRegExp.hasMatch(email.trim());

bool isValidPassword(String password) => password.length >= minPasswordLength;
