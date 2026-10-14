class User {
  final String id;
  final String username;
  final String passwordHash;
  final String role;
  final int createdAt;

  const User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password_hash': passwordHash,
        'role': role,
        'created_at': createdAt,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        username: map['username'] as String,
        passwordHash: map['password_hash'] as String,
        role: map['role'] as String,
        createdAt: map['created_at'] as int,
      );

  User copyWith({
    String? id,
    String? username,
    String? passwordHash,
    String? role,
    int? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
