# Parrot 🦜

App học tiếng Anh theo chủ đề, ôn tập bằng thuật toán SRS, game hoá theo chủ đề
**rừng rậm** với mascot con vẹt.

Dữ liệu thật trên **Firebase** (Authentication + Cloud Firestore).

## Tính năng

| Mảng | Trạng thái |
|---|---|
| Đăng nhập / đăng ký bằng email | ✅ Firebase Auth, chặn route khi chưa đăng nhập |
| 7 chủ đề × 8 từ (giáo trình dùng chung) | ✅ Firestore |
| Học từ mới: nối cặp + trắc nghiệm | ✅ Sinh từ các từ chưa học của chủ đề |
| Ôn tập theo SRS (1/3/7/21/60 ngày) | ✅ Firestore |
| Thưởng XP + hạt, streak, nhiệm vụ ngày | ✅ Firestore |
| Cửa hàng vật phẩm | ✅ Mua bằng transaction |
| Hồ sơ, 6 hạng theo tầng rừng | ✅ Suy từ XP |
| Cộng đồng: feed, xếp hạng, nhóm | ✅ Firestore (chưa có chức năng tạo bài đăng) |
| Nhận diện vật thể trong ảnh | ⚠️ Dữ liệu giả — cần dịch vụ AI, xem bên dưới |

## Chạy thử

Dự án này trỏ tới một Firebase project riêng, nên **phải tự tạo project của
bạn** — `lib/firebase_options.dart` trong repo không dùng được cho người khác.

### 1. Cài công cụ

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

Windows: thêm `%LOCALAPPDATA%\Pub\Cache\bin` vào PATH, rồi **khởi động lại**
VS Code.

### 2. Tạo và nối Firebase project

```bash
flutterfire configure --platforms=android,ios,web
```

Trên Firebase Console cần bật thêm:

- **Authentication** → *Sign-in method* → bật **Email/Password**
- **Firestore Database** → *Create database* → **production mode**, location
  `asia-southeast1`

### 3. Nạp dữ liệu và bảo mật

```bash
firebase deploy --only firestore:rules
```

Rồi nhập dữ liệu mẫu (7 chủ đề, 56 từ, 5 vật phẩm) theo
[docs/SEED_DATA.md](docs/SEED_DATA.md).

### 4. Chạy

```bash
flutter pub get
flutter run
```

> Windows cần bật **Developer Mode** (`start ms-settings:developers`) — Flutter
> dùng symlink cho plugin native.

## Kiểm tra trước khi commit

```bash
dart format .
flutter analyze
flutter test
```

## Tài liệu

| File | Nội dung |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Kiến trúc feature-first, 3 tầng `data / domain / presentation` |
| [docs/CODING_GUIDELINES.md](docs/CODING_GUIDELINES.md) | Quy tắc viết code |
| [docs/UI_SPEC.md](docs/UI_SPEC.md) | Đặc tả giao diện: design token, từng màn hình, kho ảnh |
| [docs/SEED_DATA.md](docs/SEED_DATA.md) | Dữ liệu cần nạp vào Firestore + mô hình dữ liệu |
| [docs/PLAN.md](docs/PLAN.md) | Tiến độ và việc còn lại |
| [docs/API_SPEC.md](docs/API_SPEC.md) | Hợp đồng REST API — **không còn dùng**, xem ghi chú dưới |

## Mô hình dữ liệu Firestore

```
topics/{topicId}                    name, wordCount, order
topics/{topicId}/words/{wordId}     giáo trình: english, phonetic, vietnamese
shopItems/{itemId}                  vật phẩm cửa hàng
posts/{postId}                      bài đăng cộng đồng
groups/{groupId}                    nhóm học tập

users/{uid}                         hồ sơ, XP, hạt, ngọc, streak
users/{uid}/wordProgress/{wordId}   từ nào đã học + lịch ôn SRS
users/{uid}/topicProgress/{topicId} số từ đã học của từng chủ đề
users/{uid}/savedWords/{wordId}     từ lưu từ ảnh chụp (tách khỏi phần học)
users/{uid}/dailyStats/{yyyy-MM-dd} nuôi streak và nhiệm vụ hằng ngày
users/{uid}/inventory/{itemId}      vật phẩm đang có
```

Ba thứ dễ lẫn: **giáo trình** (`topics/*/words`, admin soạn) ≠ **tiến độ học**
(`wordProgress`) ≠ **từ lưu từ ảnh** (`savedWords`).

## Hai giới hạn đã biết

**Nhận diện ảnh còn dùng dữ liệu giả.** Không phải vì chưa làm — nhận diện cần
dịch vụ AI, không phải dữ liệu trong DB. Hai đường đi tiếp:

- **Cloud Functions** gọi Vision AI, key nằm ở server → cần gói **Blaze**
- **ML Kit trên máy** (`google_mlkit_image_labeling`) → miễn phí, không cần
  server, nhưng chỉ Android/iOS

**XP gian lận được.** Security rules cho chủ sở hữu ghi hồ sơ của mình, nên
người dùng sửa trực tiếp `experience` trong Firestore được. Chỉ khắc phục bằng
Cloud Functions (cũng cần Blaze).

## Ghi chú về tầng REST

Dự án từng có một tầng gọi REST hoàn chỉnh (`lib/core/network/`, các file
`*_remote_repository.dart`, `docs/API_SPEC.md`) trước khi chuyển sang Firebase.
Phần đó **hiện không còn được dùng** nhưng vẫn giữ trong repo, để dành cho
trường hợp về sau muốn tự dựng backend riêng thay vì phụ thuộc Firebase.
