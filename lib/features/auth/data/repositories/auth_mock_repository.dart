import 'dart:async';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Xác thực trong bộ nhớ, dùng cho test widget.
///
/// Nhờ bản này mà test không cần Firebase thật: `Firebase.initializeApp()` chỉ
/// chạy trong `main()`, còn test dựng `ParrotApp` trực tiếp.
class AuthMockRepository implements AuthRepository {
  AuthMockRepository({AppUser? initialUser}) : _currentUser = initialUser {
    // Phát ngay trạng thái ban đầu để `GoRouter` không phải chờ.
    _controller.add(_currentUser);
  }

  static const _testUser = AppUser(
    id: 'test-uid',
    email: 'cong.tinh@example.com',
    displayName: 'Công Tình',
  );

  /// Bản đã đăng nhập sẵn — mặc định cho các test về màn hình bên trong app.
  factory AuthMockRepository.signedIn() =>
      AuthMockRepository(initialUser: _testUser);

  /// Bản chưa đăng nhập — dùng cho test về chặn route.
  factory AuthMockRepository.signedOut() => AuthMockRepository();

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (password.length < 6) {
      throw const AuthFailure('Email hoặc mật khẩu không đúng.');
    }
    _emit(AppUser(id: 'mock-${email.hashCode}', email: email));
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (password.length < 6) {
      throw const AuthFailure('Mật khẩu quá yếu, cần ít nhất 6 ký tự.');
    }
    _emit(
      AppUser(
        id: 'mock-${email.hashCode}',
        email: email,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<void> signOut() async => _emit(null);

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _currentUser;
    if (user == null) throw const UnauthorizedFailure();
    _emit(AppUser(id: user.id, email: user.email, displayName: name.trim()));
  }

  void _emit(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }
}
