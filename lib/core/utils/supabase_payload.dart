/// Converts blank strings to `null` so optional UNIQUE columns (e.g. aadhaar)
/// do not conflict when left empty on insert/update.
Map<String, dynamic> nullifyEmptyStrings(Map<String, dynamic> data) {
  return {
    for (final entry in data.entries)
      entry.key: entry.value is String && (entry.value as String).trim().isEmpty
          ? null
          : entry.value,
  };
}

String memberSaveErrorMessage(Object? error) {
  final message = error?.toString() ?? 'Could not save member';
  if (message.contains('members_aadhaar_number_key') ||
      message.contains('aadhaar_number')) {
    return 'This Aadhaar number is already registered';
  }
  if (message.contains('members_member_no_key') ||
      message.contains('member_no')) {
    return 'This member number is already in use';
  }
  if (message.contains('409') || message.contains('23505')) {
    return 'Duplicate value — check member no or Aadhaar';
  }
  return message.replaceFirst('Exception: ', '');
}
