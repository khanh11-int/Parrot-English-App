import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Xác thực bằng Firebase Auth (Email/Password).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  /// `userChanges()` chứ không phải `authStateChanges()`: bản sau **không** phát
  /// khi hồ sơ đổi, nên đổi tên hiển thị xong sẽ không ai hay biết.
  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toAppUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _guard(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Lưu tên hiển thị ngay để trang chủ chào đúng tên từ lần đầu.
      await credential.user?.updateDisplayName(displayName.trim());
      // `authStateChanges` đã phát trước khi tên được lưu, nên phải nạp lại để
      // `currentUser.displayName` không còn null.
      await credential.user?.reload();
    });
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  @override
  Future<void> updateDisplayName(String name) async {
    await _guard(() async {
      final user = _auth.currentUser;
      if (user == null) throw const UnauthorizedFailure();

      await user.updateDisplayName(name.trim());
      // `updateDisplayName` không tự làm mới bản đang giữ trong bộ nhớ, nên
      // `currentUser.displayName` vẫn là tên cũ nếu không nạp lại.
      await user.reload();
    });
  }

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      // Tài khoản Email/Password luôn có email; để rỗng cho chắc thay vì `!`.
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  /// Chạy một thao tác Firebase và đổi mọi lỗi thành [AuthFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error));
    }
  }

  /// Dịch mã lỗi Firebase sang câu tiếng Việt cho người dùng.
  ///
  /// Không hiện mã lỗi gốc: `wrong-password` không giúp gì cho người học.
  String _messageFor(FirebaseAuthException error) {
    return switch (error.code) {
      // Firebase gộp sai email và sai mật khẩu thành một mã, cố ý để kẻ xấu
      // không dò được email nào đã đăng ký. Thông điệp phải gộp theo.
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email hoặc mật khẩu không đúng.',
      'invalid-email' => 'Email không hợp lệ.',
      'email-already-in-use' => 'Email này đã được dùng để đăng ký.',
      'weak-password' => 'Mật khẩu quá yếu, cần ít nhất 6 ký tự.',
      'user-disabled' => 'Tài khoản này đã bị vô hiệu hoá.',
      'too-many-requests' =>
        'Bạn thử quá nhiều lần. Đợi một lát rồi thử lại nhé.',
      'network-request-failed' => 'Không có kết nối mạng.',
      'operation-not-allowed' =>
        'Đăng nhập bằng email chưa được bật cho ứng dụng.',
      _ => error.message ?? 'Không đăng nhập được. Vui lòng thử lại.',
    };
  }
}
