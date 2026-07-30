# Parrot 🦜

App học tiếng Anh: **chụp ảnh → AI nhận diện vật thể → sinh từ vựng → học và ôn
tập theo SRS**, kèm cộng đồng chia sẻ và game hoá theo chủ đề rừng rậm.

## Chạy thử

### Chế độ mock (không cần backend)

```bash
flutter pub get
flutter run
```

Không khai báo base URL thì app tự dùng dữ liệu mock — mọi màn hình mở được
ngay, không cần server. Dùng để làm UI.

### Chế độ gọi API thật

```bash
flutter run \
  --dart-define=PARROT_API_BASE_URL=https://api.parrot.example/v1 \
  --dart-define=PARROT_API_TOKEN=<token>
```

Có base URL là app tự chuyển sang gọi REST API. Xem hợp đồng API ở
[API_SPEC.md](API_SPEC.md).

> `PARROT_API_TOKEN` chỉ để tiện phát triển. Khi làm đăng nhập thật thì token
> phải đọc từ secure storage, không truyền qua `--dart-define`.

## Kiểm tra trước khi commit

```bash
dart format .
flutter analyze
flutter test
```

## Tài liệu

| File | Nội dung |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Kiến trúc feature-first + Clean Architecture rút gọn |
| [CODING_GUIDELINES.md](CODING_GUIDELINES.md) | Quy tắc viết code |
| [UI_SPEC.md](UI_SPEC.md) | Đặc tả giao diện: design token, từng màn hình, kho ảnh |
| [API_SPEC.md](API_SPEC.md) | Hợp đồng REST API cho backend |
| [PLAN.md](PLAN.md) | Tiến độ dựng app và việc còn lại |

## Trạng thái

Giao diện đã dựng đủ 8 màn hình, tầng gọi REST API đã xong phía client.
**Chưa có backend thật** — cần dựng theo `API_SPEC.md`. Các việc còn lại (camera
thật, TTS, lưu offline, đăng nhập) liệt kê ở cuối [PLAN.md](PLAN.md).
