import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// [ApiClient] dùng chung cho toàn app.
///
/// Test có thể `overrideWithValue` bằng client gắn `DioAdapter` giả để kiểm tra
/// repository mà không cần server thật.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
