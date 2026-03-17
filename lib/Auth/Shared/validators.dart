import '../../App/Manager.dart';

String? emailValidator(
  Manager manager,
  String? v, {
  String? msgRequired,
  String? msgInvalid,
}) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  final requiredMsg = msgRequired ?? s.emailRequired;
  final invalidMsg = msgInvalid ?? s.emailInvalid;
  if (t.isEmpty) return requiredMsg;
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
  return ok ? null : invalidMsg;
}

String? passwordValidator(
  Manager manager,
  String? v, {
  int min = 8,
  String? msgRequired,
}) {
  final s = manager.renovilyTranslation;
  final requiredMsg = msgRequired ?? s.passwordRequired;
  final t = v ?? '';

  if (t.isEmpty) return requiredMsg;
  if (t.length < min) return s.passwordMinChars(min);
  if (!RegExp(r'[A-Z]').hasMatch(t)) return s.passwordMustContainUppercase;
  if (!RegExp(r'[0-9]').hasMatch(t)) return s.passwordMustContainNumber;
  return null;
}

String? otpValidator(Manager manager, String? v, {int len = 6, String? msg}) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.codeRequired;
  final invalidMsg = msg ?? s.codeInvalid;
  if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(t)) return invalidMsg;
  if (t.length != len) return invalidMsg;
  return null;
}

String? phoneFrValidator(Manager manager, String? v) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.phoneRequired ?? s.required;
  if (!RegExp(r'^0\d{9}$').hasMatch(t)) return s.phoneFrInvalid;
  return null;
}

String? phoneDzValidator(Manager manager, String? v) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.phoneRequired ?? s.required;
  final ok = RegExp(r'^(?:0[5-7]\d{8}|\+213[5-7]\d{8})$').hasMatch(t);
  return ok ? null : s.phoneDzInvalid;
}

String? yearValidator(Manager manager, String? v) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.required;
  final y = int.tryParse(t);
  final now = DateTime.now().year + 1;
  if (y == null || y < 1950 || y > now) return s.yearInvalid;
  return null;
}

String? intValidator(
  Manager manager,
  String? v, {
  String? msg,
  bool allowZero = true,
}) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.required;
  final n = int.tryParse(t);
  final invalidMsg = msg ?? s.numberInvalid;
  if (n == null) return invalidMsg;
  if (!allowZero && n <= 0) return invalidMsg;
  if (n < 0) return invalidMsg;
  return null;
}

String? priceValidator(Manager manager, String? v) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').replaceAll(' ', '').replaceAll(',', '.');
  if (t.isEmpty) return s.required;
  final n = double.tryParse(t);
  if (n == null || n <= 0) return s.priceInvalid;
  return null;
}

String? matriculeDzValidator(Manager manager, String? v) {
  final s = manager.renovilyTranslation;
  final t = (v ?? '').trim();
  if (t.isEmpty) return s.required;
  return null;
}
