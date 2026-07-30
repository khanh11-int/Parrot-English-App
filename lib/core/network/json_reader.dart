import '../error/failure.dart';
import 'api_client.dart';

/// Đọc field từ JSON có kiểm kiểu, sai thì báo [ParsingFailure] kèm tên field.
///
/// Không dùng `json['key'] as int` trực tiếp: khi backend đổi schema, cách đó
/// ném `TypeError` không cho biết field nào sai, rất khó lần ra nguyên nhân.
extension JsonReader on JsonMap {
  String readString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw ParsingFailure(_message(key, 'chuỗi', value));
  }

  String? readStringOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value;
    throw ParsingFailure(_message(key, 'chuỗi', value));
  }

  int readInt(String key) {
    final value = this[key];
    if (value is int) return value;
    // JSON không phân biệt int/double, backend có thể trả 4.0 thay vì 4.
    if (value is num) return value.toInt();
    throw ParsingFailure(_message(key, 'số nguyên', value));
  }

  int readIntOr(String key, int fallback) {
    final value = this[key];
    if (value == null) return fallback;
    return readInt(key);
  }

  double readDouble(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    throw ParsingFailure(_message(key, 'số', value));
  }

  bool readBoolOr(String key, {bool fallback = false}) {
    final value = this[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    throw ParsingFailure(_message(key, 'true/false', value));
  }

  JsonMap readObject(String key) {
    final value = this[key];
    if (value is JsonMap) return value;
    throw ParsingFailure(_message(key, 'object', value));
  }

  JsonMap? readObjectOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    return readObject(key);
  }

  List<JsonMap> readObjectList(String key) {
    final value = this[key];
    if (value is List) {
      return value.whereType<JsonMap>().toList(growable: false);
    }
    throw ParsingFailure(_message(key, 'danh sách object', value));
  }

  List<String> readStringList(String key) {
    final value = this[key];
    if (value is List) return value.whereType<String>().toList(growable: false);
    throw ParsingFailure(_message(key, 'danh sách chuỗi', value));
  }

  String _message(String key, String expected, Object? actual) =>
      'Field "$key" phải là $expected nhưng nhận được ${actual.runtimeType}.';
}
