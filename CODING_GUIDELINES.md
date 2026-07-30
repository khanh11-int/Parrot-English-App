# Quy tắc viết code — Parrot 

Mục tiêu: code **dễ đọc**, **dễ review**, **dễ mở rộng**.
Quy tắc ngắn gọn, có ví dụ ✅ nên / ❌ tránh. Đọc kèm [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 1. Nguyên tắc chung

- **Rõ ràng hơn thông minh.** Code người sau đọc hiểu ngay quan trọng hơn code ngắn mà khó hiểu.
- **Một thứ làm một việc.** Mỗi hàm / class / file chỉ nên có 1 trách nhiệm.
- **Tôn trọng tầng.** `presentation → domain ← data`. Không gọi tắt (vd UI gọi thẳng API).
- **Nhất quán.** Viết giống code xung quanh: đặt tên, thứ tự, cách format.
- Luôn chạy trước khi commit:
  ```bash
  dart format .
  flutter analyze
  flutter test
  ```

---

## 2. Đặt tên

| Loại | Quy tắc | Ví dụ |
|------|---------|-------|
| File / thư mục | `snake_case` | `word_card.dart`, `vocabulary_repository.dart` |
| Class / enum / typedef | `PascalCase` | `WordCard`, `VocabularyRepository` |
| Biến / hàm / tham số | `camelCase` | `wordList`, `getWords()` |
| Hằng số | `camelCase` (không `SCREAMING`) | `defaultPadding` |
| Private (chỉ trong file) | tiền tố `_` | `_buildBody()`, `_counter` |
| Boolean | bắt đầu bằng `is/has/should` | `isLearned`, `hasError` |

- Tên phải **nói lên ý nghĩa**, tránh viết tắt khó hiểu.
  - ✅ `remainingAttempts` ❌ `ra`, `tmp`, `data2`
- Hàm là **động từ**, class/biến là **danh từ**.
  - ✅ `loadWords()`, `WordCard` ❌ `words()` cho một hàm

---

## 3. Cấu trúc file

Thứ tự import (dùng đúng nhóm, cách nhau 1 dòng trống):

```dart
// 1. Thư viện Dart
import 'dart:async';

// 2. Package bên ngoài
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. Trong dự án (dùng relative import trong cùng feature)
import '../../domain/entities/word.dart';
import '../providers/vocabulary_providers.dart';
```

- **1 class chính / 1 file.** File tên theo class đó.
- Widget quá lớn → tách thành widget con trong `presentation/widgets/`.

---

## 4. Widget

### Ưu tiên `StatelessWidget` / `ConsumerWidget`
Chỉ dùng `StatefulWidget` khi thật sự cần state cục bộ (animation, controller...).

### Tách widget bằng **class**, không phải hàm `_buildX()`
Widget con là class thì Flutter tối ưu rebuild tốt hơn và dễ đọc hơn.

```dart
// ❌ Tránh: hàm trả về Widget
Widget _buildCard() { return Card(...); }

// ✅ Nên: tách thành class riêng
class WordCard extends StatelessWidget { ... }
```

### `const` ở mọi nơi có thể
Giảm rebuild không cần thiết. Lint sẽ nhắc bạn.

```dart
// ✅
const SizedBox(height: 16),
const Text('Học từ vựng'),
```

### Widget "ngu" (dumb): nhận dữ liệu qua tham số, báo sự kiện qua callback
Không tự đọc provider / gọi API bên trong widget con → dễ tái sử dụng, dễ test.

```dart
class WordCard extends StatelessWidget {
  final Word word;              // nhận dữ liệu vào
  final VoidCallback onTap;     // báo sự kiện ra
  const WordCard({super.key, required this.word, required this.onTap});
}
```

---

## 5. Quản lý state (Riverpod)

- **`watch`** trong `build` để UI vẽ lại khi state đổi.
- **`read`** trong callback (onPressed...) để gọi hành động, **không** `read` trong `build`.

```dart
// Trong build:
final wordsAsync = ref.watch(wordListProvider);

// Trong onPressed:
onPressed: () => ref.read(learnedWordsProvider.notifier).toggle(id),
```

- Dữ liệu bất đồng bộ → dùng `AsyncValue` + `.when` để xử lý đủ 3 trạng thái:

```dart
wordsAsync.when(
  loading: () => const CircularProgressIndicator(),
  error:   (e, _) => Text('Lỗi: $e'),
  data:    (words) => ListView(...),
);
```

- **Không** để logic nghiệp vụ trong widget. Đưa vào provider / repository.

---

## 6. Data & Domain

- **Entity** (`domain/`): thuần Dart, immutable (`final` hết), không import Flutter.
- **Model / DTO** (`data/models/`): có `fromJson` / `toJson`, tách khỏi entity.
- **Repository**: là **cửa duy nhất** để lấy dữ liệu. UI/provider không gọi API trực tiếp.
- Đổi nguồn dữ liệu (mock → API → DB) chỉ sửa trong `data/`, không đụng phần khác.

```dart
// UI/provider chỉ biết repository, không biết dữ liệu từ đâu ra
final words = await repository.getWords();
```

---

## 7. Xử lý lỗi

- Không "nuốt" lỗi im lặng.
  ```dart
  // ❌
  try { ... } catch (_) {}
  ```
- Bắt lỗi ở tầng data, trả về kiểu rõ ràng (throw `Failure` hoặc trả `Result`).
- Không dùng `print` để log → dùng `debugPrint` hoặc logger.
- Tránh `!` (force unwrap) khi chưa chắc chắn null → kiểm tra rõ ràng.

---

## 8. Comment & tài liệu

- Comment giải thích **"tại sao"**, không phải **"cái gì"** (code đã nói cái gì).
  ```dart
  // ✅ Delay để giả lập gọi mạng, giúp thấy trạng thái loading
  // ❌ Gán biến i bằng 0
  ```
- Dùng `///` (doc comment) cho class / hàm public quan trọng.
- Xoá code chết, không để code comment lại "phòng khi cần".

---

## 9. Định dạng & lint

- Format tự động: `dart format .` (dòng tối đa 80 ký tự — mặc định Dart).
- Tuân theo `analysis_options.yaml` (`flutter_lints`). Không tắt lint để "cho qua".
- Dùng **trailing comma** ở list nhiều tham số → format đẹp, diff git gọn.

```dart
// ✅ có dấu phẩy cuối → mỗi tham số 1 dòng, dễ đọc diff
Column(
  children: [
    Text('a'),
    Text('b'),
  ],
)
```

---

## 10. Git commit

- Commit **nhỏ, một mục đích**. Không gom 10 việc vào 1 commit.
- Message theo dạng [Conventional Commits]:
  ```
  feat: thêm màn hình học từ vựng
  fix: sửa lỗi crash khi danh sách từ rỗng
  refactor: tách WordCard ra widget riêng
  docs: cập nhật hướng dẫn kiến trúc
  ```
- Loại hay dùng: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`.

---

## 11. Viết để dễ MỞ RỘNG

- **Tránh magic number/string.** Đưa vào `constants` hoặc enum.
  ```dart
  // ❌ if (score > 80)
  // ✅ if (score > AppConstants.passScore)
  ```
- **Nhỏ và ghép lại** hơn là một hàm/class khổng lồ.
- **Phụ thuộc vào abstraction** (interface repository) khi cần thay thế được.
- Đừng tối ưu quá sớm, nhưng cũng đừng hard-code khiến sau này khó sửa.
- Thêm tính năng mới → theo đúng khuôn feature có sẵn (xem ARCHITECTURE.md).

---

## 12. ✅ Checklist trước khi tạo Pull Request

- [ ] `dart format .` đã chạy
- [ ] `flutter analyze` không còn warning
- [ ] `flutter test` pass
- [ ] Đặt tên biến/hàm rõ nghĩa, không viết tắt khó hiểu
- [ ] Widget lớn đã tách nhỏ; đã thêm `const` nơi có thể
- [ ] Không có logic nghiệp vụ nằm trong widget
- [ ] Không còn `print`, code chết, hay `TODO` bỏ quên
- [ ] Đúng tầng kiến trúc (`presentation / domain / data`)
- [ ] Commit message rõ ràng, đúng định dạng
```

[Conventional Commits]: https://www.conventionalcommits.org/
