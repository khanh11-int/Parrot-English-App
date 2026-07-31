import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Repository xác thực.
///
/// Test override provider này bằng `AuthMockRepository` để không cần Firebase.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

/// Trạng thái đăng nhập, cập nhật liên tục.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Người dùng hiện tại đọc đồng bộ, dùng cho `GoRouter.redirect`.
final currentUserProvider = Provider<AppUser?>((ref) {
  // Theo dõi stream để provider này được tính lại khi đăng nhập/đăng xuất,
  // nhưng vẫn trả giá trị đồng bộ từ repository.
  ref.watch(authStateProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

/// Kết quả một thao tác xác thực, để UI biết hiện lỗi gì.
sealed class AuthResult {
  const AuthResult();
}

class AuthSucceeded extends AuthResult {
  const AuthSucceeded();
}

class AuthRejected extends AuthResult {
  const AuthRejected(this.message);

  final String message;
}

/// Thực hiện đăng nhập / đăng ký / đăng xuất và giữ cờ đang xử lý.
class AuthController extends Notifier<bool> {
  /// State là "đang xử lý", để nút bấm hiện spinner và không bấm được 2 lần.
  @override
  bool build() => false;

  Future<AuthResult> signIn({required String email, required String password}) {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, displayName: displayName),
    );
  }

  /// Đổi tên hiển thị. Hồ sơ tự đồng bộ xuống Firestore nhờ
  /// `profileBootstrapProvider` lắng nghe `authStateChanges`.
  Future<AuthResult> updateDisplayName(String name) =>
      _run(() => ref.read(authRepositoryProvider).updateDisplayName(name));

  Future<AuthResult> signOut() =>
      _run(() => ref.read(authRepositoryProvider).signOut());

  Future<AuthResult> _run(Future<void> Function() action) async {
    if (state) return const AuthRejected('Đang xử lý, vui lòng đợi.');

    state = true;
    try {
      await action();
      return const AuthSucceeded();
    } on Failure catch (failure) {
      return AuthRejected(failure.message);
    } finally {
      state = false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, bool>(
  AuthController.new,
);
