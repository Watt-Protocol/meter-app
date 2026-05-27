/// Logged-in app user (`waitlist_users.id` via login_waitlist_user RPC).
class AppSession {
  final int userId;
  final String email;

  const AppSession({
    required this.userId,
    required this.email,
  });

  factory AppSession.fromJson(Map<String, dynamic> json) {
    return AppSession(
      userId: json['id'] as int,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': userId,
        'email': email,
      };
}
