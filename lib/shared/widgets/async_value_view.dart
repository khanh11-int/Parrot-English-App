import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import 'app_error_view.dart';
import 'app_loading.dart';

/// Map một [AsyncValue] sang đúng 3 widget trạng thái (đang tải / lỗi / có dữ
/// liệu), để không phải lặp lại `.when(...)` ở mọi trang và không ai quên xử lý
/// một trạng thái nào.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
    this.errorMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  /// Skeleton riêng theo hình dạng nội dung của trang. Không truyền thì dùng
  /// skeleton danh sách mặc định.
  final Widget? loading;
  final VoidCallback? onRetry;

  /// Ghi đè thông điệp lỗi. Bình thường nên để trống: thông điệp lấy từ
  /// [Failure] đã đúng nguyên nhân hơn câu chung chung của từng trang.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      AsyncValue(hasError: true, :final error) => AppErrorView(
        message: errorMessage ?? _messageFor(error),
        // Lỗi không thể sửa bằng cách thử lại (hết phiên, dữ liệu sai định
        // dạng) thì ẩn nút thử lại — bấm lại chỉ ra đúng lỗi đó.
        onRetry: _isRetryable(error) ? onRetry : null,
      ),
      AsyncValue(:final valueOrNull?) => data(valueOrNull),
      _ => loading ?? const AppLoading(),
    };
  }

  String _messageFor(Object? error) => error is Failure
      ? error.message
      : 'Không tải được dữ liệu. Vui lòng thử lại.';

  bool _isRetryable(Object? error) =>
      error is Failure ? error.isRetryable : true;
}
