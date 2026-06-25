/// Parses a login field value as email or phone (E.164 for Supabase).
class LoginIdentifier {
  final bool isPhone;
  final String value;

  const LoginIdentifier({required this.isPhone, required this.value});
}

LoginIdentifier parseLoginIdentifier(String raw) {
  final trimmed = raw.trim();
  if (trimmed.contains('@')) {
    return LoginIdentifier(isPhone: false, value: trimmed.toLowerCase());
  }

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  String phone;
  if (digits.length == 10) {
    phone = '+91$digits';
  } else if (digits.length == 12 && digits.startsWith('91')) {
    phone = '+$digits';
  } else if (trimmed.startsWith('+')) {
    phone = '+$digits';
  } else {
    phone = '+$digits';
  }
  return LoginIdentifier(isPhone: true, value: phone);
}

bool isValidLoginIdentifier(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.contains('@')) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed);
  }
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 10;
}
