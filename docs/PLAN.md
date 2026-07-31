# Kế hoạch dựng giao diện Parrot

Kế hoạch thực thi cho [UI_SPEC.md](UI_SPEC.md), theo kiến trúc trong
[ARCHITECTURE.md](ARCHITECTURE.md) và quy tắc trong
[CODING_GUIDELINES.md](CODING_GUIDELINES.md).

**Nguyên tắc chung khi làm:**
- Toàn bộ dữ liệu là **mock ở tầng `data`** — chưa gọi API. Đổi sang API về sau
  chỉ sửa `data/`, UI không đổi.
- Không hard-code màu / khoảng cách / chuỗi nhãn → lấy từ `core/theme` và
  `core/constants`.
- Widget con tách thành **class**, không dùng hàm `_buildX()`.
- Sau mỗi giai đoạn: `dart format .` + `flutter analyze` phải sạch.

Ký hiệu: `[ ]` chưa làm · `[x]` đã xong

---

## Giai đoạn 0 — Chuẩn bị kho ảnh

- [x] Chuyển `lib/images/` → `assets/images/`, tách thư mục con
      `mascot/ ring/ icons/ stickers/ items/` (bỏ tiền tố khi đã có thư mục)
- [x] Khai báo assets trong `pubspec.yaml`
- [x] Viết `core/constants/app_assets.dart` (hằng số đường dẫn ảnh)

## Giai đoạn 1 — Nền tảng `core/`

- [x] `core/theme/app_colors.dart` — bảng màu mục 2.1 UI_SPEC
- [x] `core/theme/app_spacing.dart` — bậc 4px + `AppRadius`
- [x] `core/theme/app_text_styles.dart` — 9 kiểu chữ mục 2.4
- [x] `core/theme/app_theme.dart` — `ThemeData` gộp lại
- [x] `core/constants/app_labels.dart` — tên hạng / mốc / vật phẩm (mục 2.6)
- [x] Thời lượng animation — đã gộp vào `AppDurations` trong `app_spacing.dart`

## Giai đoạn 2 — Widget dùng chung `shared/widgets/`

- [x] `PrimaryButton` (có `isLoading`, `isEnabled`)
- [x] `SecondaryButton`
- [x] `AppLinearProgress`
- [x] `CurrencyPill`
- [x] `SectionHeader`
- [x] `StatTile`
- [x] `TopicChip`
- [x] `SpeakerButton`
- [x] `BadgeAvatar` (có trạng thái khoá)
- [x] `EmptyState`
- [x] `AppLoading` (skeleton)
- [x] `AppErrorView`
- [x] `AsyncValueView` — map `AsyncValue` → loading/error/data

## Giai đoạn 3 — Khung điều hướng

- [x] `core/router/app_router.dart` — `go_router` + `ShellRoute`
- [x] `shared/widgets/app_bottom_nav.dart` — 5 khe + FAB camera giữa
- [x] `main.dart` — bọc `ProviderScope`, dùng `AppTheme` + router
- [x] 4 trang gốc dạng rỗng để route chạy được

## Giai đoạn 4 — Trang chủ

- [x] Entity `domain/entities/` — `DailyGoal`, `QuestGroup`, `HomeSummary`
- [x] Mock repository `data/repositories/home_repository.dart`
- [x] Provider `presentation/providers/home_providers.dart`
- [x] Widget: `CurrencyHeader`, `ScanBanner`, `GoalProgressCard`, `QuestCard`
- [x] `home_page.dart` lắp lại + `RefreshIndicator`

## Giai đoạn 5 — Nhận diện ảnh (`image_scan`)

- [x] Entity `RecognizedWord` (có `boundingBox` tỉ lệ 0..1), `ScanResult`
- [x] Mock repository `image_scan_repository.dart`
- [x] `scan_page.dart` — chọn ảnh / mock chụp + trạng thái đang xử lý (có Huỷ)
- [x] Widget `DetectionOverlay` — vẽ khung + nhãn, bật/tắt được
- [x] `VocabCard` (biến thể `selectable`) trong `shared/widgets/`
- [x] `scan_result_page.dart` — ảnh + overlay + danh sách từ + bottom bar 2 nút
- [x] Đồng bộ 2 chiều: bấm khung ↔ làm nổi thẻ từ

## Giai đoạn 6 — Học từ mới (`quiz`)

- [x] Entity `LearnQuestion` (2 dạng: nối cặp / trắc nghiệm), `LearnSession`
- [x] Mock repository + provider quản lý vòng học
- [x] Widget `MatchPairsExercise` — 2 cột, đúng/sai có phản hồi màu
- [x] Widget `MultipleChoiceExercise` — 4 đáp án + nút Kiểm tra
- [x] `session_page.dart` — AppBar + tiến độ vòng (dùng chung cho học & ôn)
- [x] `session_summary_page.dart` — tổng kết XP / hạt

## Giai đoạn 7 — Ôn tập (`flashcard`)

- [x] Provider phiên ôn tập — `reviewSessionProvider`, dùng lại toàn bộ widget
      bài tập của giai đoạn 6
- [x] Trang phiên ôn tập — gộp vào `SessionPage(mode: review)`
- [x] `review_page.dart` (tab gốc) — danh sách bộ từ đến hạn ôn

## Giai đoạn 8 — Cộng đồng (`community`)

- [x] Entity `CommunityPost`, `LeaderboardEntry`, `StudyGroup`
- [x] Mock repository + provider
- [x] `community_page.dart` — `TabBar` 3 tab
- [x] Tab 1: `PostCard` + `VocabCard.compact` + hàng tương tác
- [x] Tab 2: header nhóm + 3 mốc `Chồi Non / Cây Vững / Đại Thụ` + XP nhóm
- [x] Tab 3: huy hiệu giải đấu + danh sách xếp hạng (ghim hàng của mình)
- [x] `StickerPicker` (bottom sheet grid) trong `shared/widgets/`
      ⚠️ đã viết nhưng chưa có chỗ gọi — cần màn hình chat nhóm / bình luận

## Giai đoạn 9 — Cửa hàng (`shop`)

- [x] Entity `ShopItem` + mock repository (4 vật phẩm mục 2.6)
- [x] `shop_page.dart` — "Vật phẩm của tôi" + "Mua ngay"
- [x] Bottom sheet xác nhận mua (chặn khi không đủ tiền)

## Giai đoạn 10 — Hồ sơ (`profile`)

- [x] Entity `UserProfile` + mock repository
- [x] `profile_page.dart` — thẻ đầu trang + `Tổng quan` 2×2 + grid bài đăng
- [x] `settings_page.dart` — danh sách mục dùng `icon_*`

## Giai đoạn 11 — Hoàn thiện

- [x] Test: 31 test pass — `domain_logic_test` (logic entity),
      `shared_widgets_test` (PrimaryButton / TopicChip / VocabCard),
      `navigation_smoke_test` (mọi route vẽ được, không tràn ở 390dp)
- [x] `dart format .` toàn bộ
- [x] `flutter analyze` sạch (0 issue)
- [x] `flutter test` pass
- [x] Cập nhật `ARCHITECTURE.md`: bổ sung 4 feature mới
      (`image_scan`, `community`, `shop`, `profile`)

---

## Ghi chú phát sinh khi làm

- `AppDurations` đặt chung trong `app_spacing.dart` thay vì file riêng — cả hai
  đều là "định lượng thiết kế", tách file riêng cho 4 hằng số là vụn.
- Route phiên ôn tập dùng `/review-session` thay cho `/review/:id` trong
  UI_SPEC, vì `/review` đã là một nhánh của `StatefulShellRoute` — để lồng
  sẽ khiến trang phiên bị kịp trong shell và vẫn hiện thanh nav.
- `AppShell` dùng `StatefulShellRoute.indexedStack` để mỗi tab giữ riêng vị trí
  cuộn; bấm lại tab đang mở thì quay về đầu tab đó.
- Icon `assets/images/icons/` là ảnh phẳng đơn sắc nên nhuộm được bằng
  `BlendMode.srcIn` để đổi màu theo tab active/inactive.

## Giai đoạn 12 — Nối REST API

Chuyển từng repository từ mock cứng sang gọi REST. Nguyên tắc: **abstract
repository ở `domain/`**, hai cài đặt ở `data/` (`*RemoteRepository` dùng REST,
`*MockRepository` giữ dữ liệu cứng). Provider chọn một theo cấu hình → app vẫn
chạy được khi chưa có backend.

- [x] Thêm `dio` vào `pubspec.yaml`
- [x] `core/config/app_config.dart` — base URL qua `--dart-define`, cờ dùng mock
- [x] `core/error/failure.dart` — phân loại lỗi + thông điệp tiếng Việt
- [x] `core/network/api_client.dart` — Dio + interceptor + map lỗi sang `Failure`
- [x] `core/network/api_endpoints.dart` — hằng số đường dẫn
- [x] `API_SPEC.md` — đặc tả endpoint cho người làm backend
- [x] `AsyncValueView` hiện thông điệp theo loại `Failure`
- [x] home: DTO + abstract + remote + mock
- [x] image_scan: DTO + abstract + remote + mock (upload multipart + poll kết quả)
- [x] quiz: DTO + abstract + remote + mock
- [x] flashcard: DTO + abstract + remote + mock
- [x] community: DTO + abstract + remote + mock (like / bookmark gọi API)
- [x] shop: DTO + abstract + remote + mock (mua gọi API)
- [x] profile: DTO + abstract + remote + mock
- [x] Test: DTO parse đúng JSON, `Failure` map đúng, test cũ vẫn pass

## Giai đoạn 13 — Sửa trang chủ & thêm trang chọn chủ đề

- [x] `AppCircularProgress` + `PercentCircularProgress` trong `shared/widgets/`
- [x] Trang chủ: lời chào + nhóm số đếm trong khối trắng bo tròn
- [x] Trang chủ: 2 thẻ mục tiêu cạnh nhau, vòng tiến độ + mascot ở giữa
- [x] Trang chủ: nhiệm vụ tháng gọn 1 dòng, nhiệm vụ ngày có thanh full width
- [x] `HomeSummary.userName` + DTO + mock
- [x] Entity `VocabularyTopic` (tiến độ suy từ learned/total)
- [x] `LearnRepository.getTopics()` + DTO + mock + remote + `GET /me/topics`
- [x] `TopicProgressTile` — vòng tiến độ + tên + số từ + chip trạng thái
- [x] `TopicListPage` tại `/learn` + thẻ tổng + nút học trộn mọi chủ đề
- [x] Phiên học nhận theo chủ đề: `sessionProvider` thành family theo
      `(mode, topicId)`, route `/learn/session?topic=<id>`
- [x] Cập nhật test (50 test pass) + UI_SPEC mục 5.1 và 5.4 + API_SPEC

## Giai đoạn 14 — Firebase + đăng nhập

- [x] Tạo Firebase project `parrot-english-app` + Firestore `(default)`
      (STANDARD, `asia-southeast1`)
- [x] `flutterfire configure` — sinh `firebase_options.dart`,
      `google-services.json`, vá plugin Gradle
- [x] Package `firebase_core` `firebase_auth` `cloud_firestore`
- [x] `Firebase.initializeApp()` trong `main.dart`
- [x] Bật Windows Developer Mode + Email/Password trên Console
- [x] `AppUser` + `AuthRepository` (abstract) + `AuthFailure`
- [x] `FirebaseAuthRepository` — dịch mã lỗi Firebase sang câu tiếng Việt
- [x] `AuthMockRepository` — cho test, không cần Firebase
- [x] `authStateProvider` / `currentUserProvider` / `AuthController`
- [x] `AppTextField` + `AuthValidators` trong `shared/widgets/`
- [x] `LoginPage` + `RegisterPage`
- [x] Chặn route: `routerProvider` + `redirect` + `refreshListenable`
- [x] Nút đăng xuất trong Cài đặt (có hỏi xác nhận)
- [x] Lời chào trang chủ lấy tên người đăng nhập thật
- [x] Test: 63 test pass (`test/helpers/test_app.dart` + `test/auth_test.dart`)

### Còn lại của mảng Firebase
- [x] Security rules cho Firestore — `firestore.rules`, đã deploy, kiểm thật
      8/8 (chặn ghi `topics`/`shopItems`, chặn ghi hồ sơ người khác, chặn mạo
      danh bài đăng, chặn đọc khi chưa đăng nhập)
- [x] Tạo document `users/{uid}` khi đăng nhập — `profileBootstrapProvider`,
      idempotent, `getProfile` cũng tự tạo lại nếu thiếu
- [x] `FirebaseProfileRepository` + `UserDocument` — **trang Hồ sơ đã dùng dữ
      liệu thật từ Firestore**
- [x] `FirebaseTopicRepository` — tách `TopicRepository` ra khỏi
      `LearnRepository`; ghép `topics` + `users/{uid}/topicProgress`
- [x] `FirebaseShopRepository` — ghép `shopItems` + ví + `inventory`; mua bằng
      **transaction** để trừ tiền và cộng vật phẩm không tách được
- [x] Nhập dữ liệu mẫu `topics` (7, nhập tay) + `shopItems` (5, script)
      — đã đối chiếu 12/12 document đúng schema; xem `SEED_DATA.md`
- [x] **Sửa mô hình dữ liệu** — từ vựng là **giáo trình** `topics/{id}/words`
      (admin soạn, dùng chung), không phải sinh ra từ ảnh chụp. Ba collection
      độc lập: giáo trình / `wordProgress` (tiến độ + SRS) / `savedWords`
      (từ lưu từ ảnh, không dính phần học)
- [x] Seed 56 từ (8 × 7 chủ đề) vào `topics/{id}/words` + `wordCount` khớp
- [x] `FirebaseLearnRepository` — học từ mới = từ chưa học trong chủ đề;
      ôn tập = từ đã học đến hạn theo SRS
- [ ] 3 `*FirebaseRepository` còn lại: home, flashcard (danh sách bộ từ),
      community
- [x] Trang xem `savedWords` — vào từ Cài đặt, xoá được từng từ
- [x] Tạo bài đăng thật — nút "Lưu và đăng tải" trước đây nói dối:
      `shouldPost` được truyền vào nhưng không dùng ở đâu
- [x] Tính streak — trước đây `streakDays` chỉ đọc, không bao giờ được ghi
- [ ] Khóa ghi `experience`/`seeds`/`gems` — rules hiện cho chủ sở hữu tự ghi
      nên XP **gian lận được**; chỉ sửa được bằng Cloud Functions (gói Blaze)
- [ ] Cloud Functions cho AI nhận diện ảnh (cần gói Blaze)
- [ ] Quyết định: bỏ hay giữ tầng REST ở giai đoạn 12 (`dio`, `api_client`,
      6 `*_remote_repository.dart`, `API_SPEC.md`)

---

## Đã xong — còn lại gì

Toàn bộ giao diện đã dựng với dữ liệu mock. Những việc **cố ý để lại**
vì cần quyết định hoặc phụ thuộc bên ngoài:

### Cần package / backend
- [ ] Camera thật (`camera` hoặc `image_picker`) — `ScanPage` đang dùng khung
      xem trước giả
- [ ] Phát âm TTS (`just_audio` / `flutter_tts`) — `SpeakerButton` hiện chỉ báo
      "sẽ có ở bản sau"
- [x] Tầng gọi REST API — xong phía client, xem `API_SPEC.md`
- [ ] **Backend thật** — cần người dựng theo `API_SPEC.md`, đã bao gồm proxy
      gọi AI (KHÔNG nhúng API key trong app)
- [ ] Đăng nhập + refresh token + lưu token bằng `flutter_secure_storage`
      (hiện token đọc từ `--dart-define`, chỉ để tiện phát triển)
- [ ] Lưu offline (`isar` / `drift`) cho bộ từ và lịch ôn SRS
- [x] Thuật toán SRS thật — `AppRewards.nextIntervalDays`, mốc
      `[0, 1, 3, 7, 21, 60]` ngày, ghi vào `users/{uid}/wordProgress`. Mốc đầu
      **0 ngày** để từ vừa học ôn lại được ngay trong ngày

### Cần thiết kế thêm (xem mục 11.4 UI_SPEC)
- [x] 6 huy hiệu hạng theo tầng rừng — có ảnh ở `assets/images/ranks/`,
      lấy bằng `AppAssets.rankBadge(rank.index)`
- [ ] **Nối** 6 huy hiệu đó vào Hồ sơ + Bảng xếp hạng (vẫn đang dùng
      `itemTarget` / `itemLock` tạm)
- [ ] Xoá nền cho bộ ảnh mới bằng `tools/strip_assets.py` — nhiều ảnh còn khung
      nền bo góc, đặt cạnh ảnh cũ thấy lệch
- [ ] Nối `assets/images/topics/` vào `TopicDocument.iconAssetFor`
- [ ] 3 huy hiệu mốc nhóm: mầm → cây con → đại thụ
- [ ] Icon **hạt** riêng (hiện dùng `items/coin.png`). XP tạm dùng
      `Icons.eco_rounded` — trước đây dùng ảnh kim cương, người học tưởng vừa
      nhận được ngọc
- [ ] Hoạ tiết nền lá cây `pattern/leaves.png`
- [x] Cắt bỏ chữ tiếng Việt + xoá nền thành trong suốt + crop sát hình
      cho 43 ảnh — script `tools/strip_assets.py`, bản gốc ở
      `assets/images_original/`. Riêng 4 ảnh `ring/*` vẫn còn số (`9/15`...)
      vì số nằm trong vòng tiến độ
- [ ] Xuất `@2x` / `@3x` (hoặc SVG cho nhóm icon)

### Chức năng còn trống
- [x] Chat nhóm & bình luận — cùng một `MessageThreadPage`, dùng
      `StickerPicker` đã viết từ trước. `Stream` nên thấy tin người khác ngay.
- [x] Tạo nhóm / tham gia nhóm / rời nhóm — thành viên là
      `users/{uid}.groupId`, số liệu nhóm tính bằng aggregate `count()`/`sum()`
      nên không cần mở quyền ghi vào document nhóm
- [ ] Trang chi tiết nhiệm vụ tháng
- [ ] Các mục con trong Cài đặt (đang `onTap: null`)
- [ ] `/user/:id` — trang cá nhân của người khác
- [x] Feature `vocabulary` — đã dựng (giáo trình + tiến độ từng từ + từ đã lưu)
- [ ] Feature `progress` (trang thống kê học tập) — chưa dựng. Thư mục khung đã
      xoá; tạo lại khi viết file đầu tiên
