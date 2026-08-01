# Kiến trúc dự án Parrot 

App học tiếng Anh, dùng **Feature-first + Clean Architecture (rút gọn)**.
Đề xuất state management: **Riverpod** (đã khai báo sẵn trong `pubspec.yaml`).

> **Trạng thái:** toàn bộ giao diện đã dựng với dữ liệu **mock ở tầng `data`**
> (chưa gọi API). Đặc tả UI ở [UI_SPEC.md](UI_SPEC.md), tiến độ ở
> [PLAN.md](PLAN.md).

## Ý tưởng cốt lõi

Chia theo **tính năng (feature)**, mỗi tính năng chia làm **3 tầng**:

```
presentation  →  UI + provider        (thứ người dùng thấy)
     ↓ gọi
domain        →  entity nghiệp vụ      (thuần Dart, không dính Flutter)
     ↑ trả về
data          →  API / DB / mock       (nguồn dữ liệu)
```

**Quy tắc phụ thuộc:** `presentation → domain ← data`.
Tầng `domain` không biết gì về Flutter hay API → dễ test, dễ thay đổi.

## Cây thư mục

```
lib/
├── main.dart                # điểm khởi động app
│
├── core/                    # dùng chung TOÀN app
│   ├── theme/               # màu sắc, ThemeData
│   ├── router/              # cấu hình điều hướng (go_router)
│   ├── constants/           # hằng số (padding, mức thưởng, đường dẫn ảnh)
│   ├── providers/           # provider dùng chung nhiều feature
│   ├── network/             # client gọi API (tầng REST, hiện không dùng)
│   └── error/               # class lỗi (Failure)
│
├── features/                # mỗi tính năng 1 thư mục, cùng 1 khuôn
│   ├── auth/                # đăng nhập / đăng ký (Firebase Auth)
│   ├── home/                # trang chủ: mục tiêu ngày + nhiệm vụ
│   ├── image_scan/          # chụp ảnh → nhận diện vật thể → liệt kê từ
│   ├── quiz/                # chọn chủ đề + phiên học từ mới
│   ├── flashcard/           # ôn tập theo SRS
│   ├── vocabulary/          # giáo trình từ vựng + tiến độ từng từ
│   ├── community/           # feed, nhóm học tập, bảng xếp hạng
│   ├── shop/                # cửa hàng vật phẩm
│   └── profile/             # trang cá nhân + cài đặt
│       ├── data/
│       │   ├── models/          # đọc/ghi document Firestore
│       │   └── repositories/    # trả về entity, nơi DUY NHẤT chạm SDK
│       ├── domain/
│       │   ├── entities/        # object nghiệp vụ thuần Dart
│       │   └── repositories/    # interface trừu tượng (khi cần)
│       └── presentation/
│           ├── providers/       # state (Riverpod)
│           ├── pages/           # màn hình
│           └── widgets/         # widget con của feature
│
└── shared/
    └── widgets/             # widget tái sử dụng giữa nhiều feature
```

**Không có tầng `datasources/`.** Khuôn Clean Architecture đầy đủ đặt phần chạm
SDK ở `data/datasources/` rồi `data/repositories/` chỉ lo map DTO → entity. Ở
quy mô này thì đó là một lớp trung gian chỉ chuyển tiếp lời gọi, nên repository
gọi `FirebaseFirestore` trực tiếp (xem `FirebaseVocabularyRepository`). Điều cần
giữ vẫn giữ: `presentation` và `domain` không import `cloud_firestore`.

Thư mục chỉ tạo khi có file thật — không để sẵn thư mục rỗng cho việc tương lai,
vì mở ra thấy trống lại tưởng mất file. Feature/thư mục còn thiếu ghi ở
[PLAN.md](PLAN.md).

Ngoài `lib/` còn có `assets/images/` chia theo `mascot/ ring/ icons/ stickers/
items/`; đường dẫn khai báo tập trung ở `core/constants/app_assets.dart`.

> Feature `home` là mẫu tham khảo đầy đủ nhất của khuôn 3 tầng: entity thuần
> Dart ở `domain/`, mock repository ở `data/`, provider + page + widget ở
> `presentation/`. Các feature khác theo đúng khuôn đó.

## Thêm 1 feature mới

1. Tạo `features/<tên>/` với 3 thư mục `data / domain / presentation`.
2. Viết `entity` trong `domain/`, `repository` trong `data/`.
3. Viết `provider` + `page` trong `presentation/`.
4. Đăng ký route trong `core/router/`.

## Vì sao dễ mở rộng?

- **Đổi nguồn dữ liệu** (mock → Firebase → API): chỉ sửa tầng `data`.
- **Đổi giao diện**: chỉ sửa `presentation`.
- **Nhiều người làm song song**: mỗi người 1 feature, ít đụng nhau.
- **Test dễ**: `domain` thuần Dart; provider có thể inject repository giả.

## Tích hợp AI (kế hoạch tương lai)

Dự kiến thêm 2 tính năng dùng AI. Cả hai **không phá kiến trúc** — chỉ là các
`feature` mới theo đúng khuôn 3 tầng. Điểm mấu chốt: coi AI như **một nguồn dữ
liệu** → toàn bộ phần gọi AI nằm ở tầng `data`, UI không biết gì về SDK/API AI.

### A. Chatbot AI (luyện hội thoại / hỏi đáp)

```
features/chatbot/
├── data/
│   ├── models/        # DTO request/response của API
│   └── repositories/  # ChatRepository: gửi tin nhắn, nhận trả lời
│                      # nơi DUY NHẤT chạm SDK/API AI
├── domain/
│   ├── entities/      # ChatMessage (role: user/assistant, nội dung, thời điểm)
│   └── repositories/  # interface ChatRepository (để mock khi test)
└── presentation/
    ├── providers/     # quản lý danh sách tin nhắn + trạng thái "đang trả lời"
    ├── pages/         # màn hình chat
    └── widgets/       # bong bóng chat, ô nhập...
```

Lưu ý khi làm:
- **Streaming**: câu trả lời nên hiện dần từng chữ → dùng `Stream<String>` từ
  repository, provider gom lại. Hợp với `StreamProvider` / `AsyncNotifier`.
- **Ngữ cảnh hội thoại**: gửi kèm lịch sử tin nhắn để AI trả lời mạch lạc.
- **Prompt hệ thống**: cấu hình "gia sư tiếng Anh" đặt trong `data/` hoặc `core/`.

### B. Nhận diện hình ảnh → lấy từ vựng (OCR / Vision AI)

Chụp/chọn ảnh → AI đọc chữ trong ảnh → tách ra từ vựng để học.

```
features/image_scan/
├── data/
│   ├── models/        # DTO kết quả nhận diện
│   └── repositories/  # ImageScanRepository: ảnh vào → danh sách từ ra
│                      # nơi DUY NHẤT gọi Vision API / OCR
├── domain/
│   ├── entities/      # RecognizedWord (từ, vị trí trong ảnh, độ tin cậy)
│   └── repositories/
└── presentation/
    ├── providers/     # trạng thái: chọn ảnh → đang xử lý → kết quả
    ├── pages/         # màn hình chụp/chọn ảnh + xem kết quả
    └── widgets/       # khung chọn ảnh, danh sách từ nhận được
```

Luồng: chọn ảnh (`image_picker`) → gửi ảnh cho `ImageScanRepository` →
nhận `List<RecognizedWord>` → cho phép người dùng lưu vào feature `vocabulary`
(tái dùng lại entity/repository của vocabulary — các feature có thể gọi nhau
qua tầng domain, không copy code).

### ⚠️ Quy tắc chung khi tích hợp AI

- **KHÔNG nhúng API key trong app.** App mobile dễ bị dịch ngược → lộ key.
  Nên gọi AI qua **backend trung gian (proxy)** của mình; app chỉ nói chuyện
  với backend đó. Key nằm ở server.
- **Xử lý tốt trạng thái chờ & lỗi**: AI có độ trễ và có thể thất bại/timeout →
  luôn có loading + thông báo lỗi + nút thử lại (dùng `AsyncValue`).
- **Chi phí & giới hạn**: gọi AI tốn tiền/quota → cân nhắc cache kết quả, chặn
  spam, giới hạn số lần gọi.
- **Trừu tượng hoá nhà cung cấp**: định nghĩa interface repository ở `domain/`,
  cài đặt cụ thể ở `data/`. Đổi nhà cung cấp AI về sau chỉ sửa tầng `data`.

## Package gợi ý (thêm khi cần)

- `flutter_riverpod` — quản lý state *(đã có)*
- `go_router` — điều hướng *(đã có)*
- `dio` + `retrofit` — gọi API
- `isar` / `drift` — lưu offline (rất cần cho app học tập)
- `freezed` + `json_serializable` — model immutable + parse JSON
- `flutter_tts` — phát âm từ tiếng Anh (chưa làm, xem `docs/PLAN.md`)

Cho tính năng AI (khi làm tới):
- `image_picker` / `camera` — chụp hoặc chọn ảnh từ máy
- `dio` — gọi API AI (chatbot & vision) qua backend trung gian
- (tuỳ chọn) `google_mlkit_text_recognition` — OCR **chạy offline trên máy**,
  không cần gửi ảnh lên mạng; hợp cho việc chỉ cần đọc chữ đơn giản
