class NotificationModel {
  final String id;
  final String? memberId;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.memberId,
    required this.title,
    required this.message,
    this.notificationType = 'General',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        memberId: json['member_id'] as String?,
        title: json['title'] as String,
        message: json['message'] as String,
        notificationType:
            json['notification_type'] as String? ?? 'General',
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
