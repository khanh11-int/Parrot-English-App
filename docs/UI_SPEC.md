# Đặc tả giao diện — Parrot

Tài liệu này mô tả **toàn bộ giao diện** cần dựng, suy ra từ bộ ảnh chụp màn hình
bản demo. Dùng làm nguồn tham chiếu duy nhất khi code UI, để nhiều người làm song
song mà vẫn ra cùng một phong cách.

> **Lưu ý về màu:** các mã màu bên dưới được **ước lượng từ ảnh chụp** (ảnh chụp
> qua màn hình nên bị lệch sáng/màu). Khi có file design chính thức thì cập nhật
> lại `core/theme/app_colors.dart` — mọi màn hình đọc màu từ theme nên chỉ cần
> sửa một chỗ.

---

## 1. Tinh thần thiết kế

| Yếu tố | Quyết định |
|---|---|
| Chủ đề hình ảnh | **Rừng rậm nhiệt đới**, mascot **con vẹt** (đúng tên app *Parrot*) |
| Cảm giác | Vui, tròn trịa, nhiều khoảng trắng, giống app game hoá (Duolingo-like) |
| Màu chủ đạo | Xanh dương (nút, tab đang chọn, thẻ nhấn mạnh) — khớp bộ lông cánh vẹt |
| Màu phụ | Xanh lá (lá cây, tán rừng) + vàng nắng |
| Nền | Trắng → xanh lá rất nhạt (gradient nhẹ), không dùng nền tối |
| Hoạ tiết | Lá cây, dây leo, tán rừng — mờ 5–8%, chỉ ở header và thẻ lớn |
| Bo góc | To và mềm (12–24px), gần như không có góc vuông |
| Đổ bóng | Rất nhẹ, chỉ để tách thẻ khỏi nền |
| Ngôn ngữ | Toàn bộ nhãn UI là **tiếng Việt**; từ vựng tiếng Anh in nổi bật |

**Ẩn dụ xuyên suốt:** người học là **con vẹt leo dần lên các tầng rừng**. Học và
ôn tập đổi ra `hạt` (tiền mềm), tích XP để lên tầng cao hơn; nhóm học tập cùng
nhau "trồng" một cây từ *chồi non* thành *đại thụ*.

> Màu chủ đạo vẫn là **xanh dương**, không đổi sang xanh lá — vì cánh vẹt trong
> bộ mascot màu xanh dương và toàn bộ nút/tab hiện tại đã theo màu này. Chủ đề
> rừng thể hiện qua **nền, hoạ tiết, tên hạng và tên vật phẩm**. Nếu muốn đổi
> hẳn `primary` sang xanh lá thì chỉ cần sửa `app_colors.dart`.

---

## 2. Design tokens

### 2.1 Màu — `core/theme/app_colors.dart`

```dart
// Thương hiệu
primary        #2E6BE6  // nút chính, tab active, viền thẻ được chọn
primaryDark    #1F4FBF  // trạng thái nhấn (pressed)
primaryLight   #E8F0FE  // nền thẻ nhạt, chip

// Rừng (màu phụ — gradient, hoạ tiết, huy hiệu)
leaf           #43B02A  // xanh lá tươi: gradient banner, nút camera nổi
leafDark       #2E7D22  // tán rừng sâu, chữ trên nền lá nhạt
leafLight      #E7F6E3  // nền mục, hoạ tiết lá
canopy         #1B5E3A  // xanh rừng đậm: header nhóm, thẻ gradient
sun            #FFC93C  // vàng nắng xuyên tán: điểm nhấn, huy hiệu

// Nền
bgBase         #FFFFFF
bgSoft         #F5FAF3  // nền scaffold (hơi ngả xanh lá)
bgGradient     linear(180°, #EAF7E6 → #FFFFFF)

// Ngữ nghĩa
success        #7FD69B  // ô ghép cặp, đáp án đúng
successSoft    #DFF5E6
danger         #E5534B  // đáp án sai
warning        #FFB020  // streak (lửa)
neutral        #EEF0F4  // ô đáp án chưa chọn, nút disabled

// Chữ
textPrimary    #1B2430
textSecondary  #6B7684  // nghĩa tiếng Việt, phiên âm, mô tả
textOnPrimary  #FFFFFF
textDisabled   #A7B0BD

// Đường kẻ
divider        #E4E8EF

// Tiền tệ trong app
coinSeed       #D99A2B  // "hạt" — tiền mềm, kiếm bằng học tập
coinGem        #17B978  // "ngọc" (lục bảo) — tiền cứng
```

> `success` và `leaf` đều là xanh lá nhưng **không thay thế nhau**: `success` chỉ
> dùng cho phản hồi đúng/sai trong bài học, `leaf` dùng cho trang trí chủ đề.
> Trộn hai vai trò này sẽ làm người học tưởng thẻ trang trí là "đáp án đúng".

### 2.2 Khoảng cách — `core/constants/app_spacing.dart`

Bậc 4px: `xs 4` · `sm 8` · `md 12` · `lg 16` · `xl 24` · `xxl 32`

- Lề ngang mặc định của trang: **16**
- Khoảng cách giữa 2 thẻ trong danh sách: **12**
- Padding trong thẻ: **16**

### 2.3 Bo góc — `AppRadius`

`chip 999` (viên thuốc) · `card 16` · `cardLarge 24` · `button 12` · `image 12`

### 2.4 Kiểu chữ — `AppTextStyles`

| Tên | Cỡ / độ đậm | Dùng ở đâu |
|---|---|---|
| `displayNumber` | 32 / w700 | Số XP lớn ("355", "568") |
| `titleLarge` | 22 / w700 | Tiêu đề màn hình ("Trang cá nhân", "Cửa hàng") |
| `titleMedium` | 18 / w600 | Tiêu đề mục ("Tổng quan", "Mua ngay") |
| `wordEnglish` | 18 / w700 | Từ tiếng Anh ("chair", "person") |
| `wordPhonetic` | 13 / w400 / italic | Phiên âm IPA `/tʃeə(r)/` |
| `wordMeaning` | 14 / w400 | Nghĩa tiếng Việt |
| `body` | 14 / w400 | Chữ thường |
| `caption` | 12 / w400 / textSecondary | "5 tháng trước", "8 thành viên" |
| `button` | 15 / w600 | Chữ trên nút |

### 2.5 Icon & mascot

- Icon hệ thống: Material Symbols (rounded).
- Mascot **con vẹt**: bộ lông xanh lục – vàng – xanh dương, mỏ đen cong, chân
  mào nhỏ; dáng tròn trịa, mắt to. Đã có sẵn bộ ảnh — xem **mục 11**.
- Huy hiệu rank: **tổ vẹt trên tầng cây**, mỗi hạng một tầng rừng cao hơn; có
  trạng thái **đã mở** (màu) và **chưa mở** (xám + dấu `?`).
- Hoạ tiết nền: lá cây / dây leo, đặt ở `assets/images/pattern/`, luôn dùng ở độ
  mờ 5–8% để không cạnh tranh với nội dung.

### 2.6 Bộ tên gọi theo chủ đề rừng

Toàn bộ tên hạng, mốc và vật phẩm dùng **một bộ từ vựng duy nhất** dưới đây. Đặt
ở `core/constants/app_labels.dart` để không viết chuỗi rải rác trong UI.

#### Tiền tệ

| Token | Tên hiển thị | Vai trò | Cách kiếm |
|---|---|---|---|
| `coinSeed` | **Hạt** 🌰 | Tiền mềm | Học từ mới, ôn tập, hoàn thành nhiệm vụ |
| `coinGem` | **Ngọc** 💎 | Tiền cứng | Mốc dài hạn, sự kiện, nạp |

XP vẫn gọi là **Kinh nghiệm**, hiển thị kèm icon lá (`leaf`).

#### Thang hạng cá nhân (6 tầng rừng)

| # | Tên hạng | Ngưỡng XP (đề xuất) |
|---|---|---|
| 1 | **Thảm Rừng** | 0 |
| 2 | **Bụi Rậm** | 500 |
| 3 | **Tán Thấp** | 1 500 |
| 4 | **Tán Giữa** | 4 000 |
| 5 | **Tán Cao** | 10 000 |
| 6 | **Vượt Tán** | 25 000 |

Ẩn dụ: vẹt leo từ mặt đất lên ngọn cây cao nhất. Mỗi hạng một huy hiệu tổ vẹt
riêng, tầng càng cao thì nền càng nhiều ánh nắng.

#### Mốc nhóm học tập (3 mốc)

| Mốc | Ngưỡng XP nhóm | Ý nghĩa |
|---|---|---|
| **Chồi Non** | 600 | Nhóm vừa hình thành |
| **Cây Vững** | 16 000 | Nhóm học đều |
| **Đại Thụ** | 30 000 | Nhóm đứng đầu |

#### Vật phẩm Cửa hàng

| Tên | Tác dụng | Giá | Asset |
|---|---|---|---|
| **Quả Tăng Tốc** | Nhân đôi XP trong 15 phút | 150 Hạt | `item_energy.png` |
| **Khiên Vỏ Cây** | Giữ chuỗi streak khi nghỉ 1 ngày | 200 Hạt | `item_shield.png` |
| **Bình Mật Hoa** | Tăng 25% XP toàn app trong 24 giờ | 2 Ngọc | `item_gift.png` |
| **Sticker vẹt** | Dùng sticker trong chat nhóm & bình luận | 2 Ngọc | `sticker_*.png` |

---

## 3. Khung điều hướng

### 3.1 Bottom navigation (5 khe, khe giữa là nút nổi)

```
┌──────────────────────────────────────────────┐
│  🏠        📖       ( 📷 )      👥       👤   │
│ Trang chủ  Ôn tập    FAB     Cộng đồng  Hồ sơ │
└──────────────────────────────────────────────┘
```

- Nút giữa: **FAB tròn màu xanh, icon camera**, nổi cao hơn thanh nav
  → mở luồng *Nhận diện ảnh → sinh từ vựng* (tính năng cốt lõi của app).
- Tab đang chọn: icon + nhãn màu `primary`; tab khác `textSecondary`.
- Thanh nav luôn hiện ở 5 tab gốc, **ẩn** trong các luồng học/quiz và các trang
  con push toàn màn hình (Cửa hàng, Kết quả nhận diện...).

### 3.2 Sơ đồ route — `core/router/app_router.dart`

```
/                       ShellRoute (bottom nav)
├── /home               Trang chủ
├── /review             Ôn tập
├── /community          Cộng đồng   (3 tab con)
│   ├── ?tab=feed       Dòng thời gian
│   ├── ?tab=group      Nhóm học tập
│   └── ?tab=rank       Bảng xếp hạng
└── /profile            Hồ sơ

/scan                   Chụp / chọn ảnh            (fullscreen)
/scan/result            Kết quả nhận diện          (fullscreen)
/learn                  Chọn chủ đề để học          (fullscreen)
/learn/session?topic=   Phiên học từ mới             (fullscreen, ẩn nav)
/review/:sessionId      Phiên ôn tập SRS            (fullscreen, ẩn nav)
/shop                   Cửa hàng
/settings               Cài đặt
/user/:id               Trang cá nhân người khác
```

---

## 4. Thư viện widget dùng chung

Đặt ở `lib/shared/widgets/`. **Dựng nhóm này trước khi dựng màn hình** — mọi
màn hình đều lắp từ đây.

| Widget | Mô tả | Xuất hiện ở |
|---|---|---|
| `PrimaryButton` | Nút xanh đầy, bo 12, cao 48, full width; có `isLoading`, `isEnabled` | Khắp app |
| `SecondaryButton` | Nút viền xanh, nền trắng | "Lưu và đăng tải" |
| `TopicChip` | Chip viên thuốc "chọn chủ đề ˅", mở bottom sheet | Thẻ từ vựng |
| `CurrencyPill` | Icon + số (hạt / ngọc / streak) | Header trang chủ, Cửa hàng |
| `ProgressCard` | Thẻ có tiêu đề + thanh tiến độ + tỉ lệ `9/15` | Trang chủ |
| `LinearProgress` | Thanh tiến độ bo tròn, cao 8 | Nhiệm vụ, mốc nhóm |
| `VocabCard` | Thẻ 1 từ: radio chọn, từ EN, IPA, nghĩa VI, chip chủ đề, nút loa | Kết quả nhận diện, Feed |
| `SpeakerButton` | Nút loa tròn, có trạng thái đang phát | `VocabCard` |
| `BadgeAvatar` | Huy hiệu tròn, hỗ trợ trạng thái khoá (xám + `?`) | Rank, mốc nhóm |
| `SectionHeader` | Tiêu đề mục + slot hành động bên phải | Nhiều trang |
| `StatTile` | Ô thống kê: icon + nhãn nhỏ + giá trị | "Tổng quan" hồ sơ |
| `EmptyState` | Mascot + câu dẫn + nút hành động | Danh sách rỗng |
| `AppLoading` / `AppErrorView` | Trạng thái chờ / lỗi + nút thử lại | Mọi chỗ gọi API |

### 4.1 `VocabCard` — widget quan trọng nhất

```
┌────────────────────────────────────────────────┐
│ ◯  chair                                       │
│    /tʃeə(r)/ – cái ghế                     🔊  │
│    Chủ đề: [ chọn chủ đề ˅ ]                   │
└────────────────────────────────────────────────┘
```

Quy tắc:
- `◯` là **radio/checkbox chọn để lưu**; chọn rồi thì viền thẻ đổi sang
  `primary` và nền sang `primaryLight`.
- Nghĩa tiếng Việt và IPA nằm cùng dòng, phân cách bằng ` – `, màu
  `textSecondary`.
- Nút loa ở góc phải, đọc từ tiếng Anh (TTS).
- Chip chủ đề: chưa chọn thì hiện "chọn chủ đề", chọn rồi hiện tên chủ đề.
- Có 2 biến thể: `VocabCard.selectable` (trong kết quả nhận diện) và
  `VocabCard.compact` (nhúng trong bài đăng ở feed, kèm nút "Lưu từ vựng").

---

## 5. Đặc tả từng màn hình

### 5.1 Trang chủ — `/home`

```
┌──────────────────────────────────────┐
│ Chào Công Tình 👋   ╭──────────────╮ │  lời chào + nhóm số đếm
│ Hôm nay học gì nhỉ? │🔥1 💎2 🌰15  │ │  gom trong khối trắng bo tròn
│                     ╰──────────────╯ │
│ ╭──────────────────────────────────╮ │
│ │ Gửi ảnh học từ mới!          🦜  │ │  banner gradient leaf→canopy
│ │ [Gửi ảnh]                        │ │
│ ╰──────────────────────────────────╯ │
│ ╭───────────────╮ ╭───────────────╮  │
│ │      🦜       │ │      🦜       │  │  chỉ mascot + nhãn
│ │  Học từ mới   │ │  Ôn tập ngay  │  │
│ ╰───────────────╯ ╰───────────────╯  │
│  nền primary        nền trắng        │
│                                      │
│ Nhiệm vụ                             │
│ ╭──────────────────────────────────╮ │
│ │ 📅 Nhiệm vụ tháng Chín    15% ›  │ │  dải 1 dòng, nền leafLight
│ ╰──────────────────────────────────╯ │
│ ╭──────────────────────────────────╮ │
│ │ ○ Lưu 5 từ mới qua hình ảnh  3/5 │ │
│ │   ▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░  │ │  thanh full width
│ │ ─────────────────────────────────│ │
│ │ ○ Ôn tập 30 từ vựng         0/30 │ │
│ │   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │ │
│ ╰──────────────────────────────────╯ │
└──────────────────────────────────────┘
```

Chi tiết:
- **Lời chào** cho trang một điểm neo cho mắt, thay vì mở app ra là một hàng số
  trơ trọi. Tên lấy từ `HomeSummary.userName`.
- **Ba số đếm** gom trong một khối trắng bo tròn → đọc như một nhóm, không lẫn
  vào nền trang. Bấm ngọc/hạt mở Cửa hàng.
- **Banner**: gradient `leaf → canopy`, mascot bên phải, nhãn trắng "Gửi ảnh".
  Cả banner là một vùng bấm → `/scan`.
- **2 thẻ hành động** xếp cạnh nhau, chia đều chiều ngang, bọc `IntrinsicHeight`
  để luôn cao bằng nhau. Mỗi thẻ **chỉ có mascot + tên hành động** — không có
  vòng tiến độ, không có số từ.
  - Lý do: trang chủ chỉ cần trả lời "bấm vào đâu để học". Tiến độ chi tiết đã
    có ở trang chọn chủ đề (5.4); nhắc lại ở đây làm thẻ rối mà không giúp người
    dùng quyết định nhanh hơn.
  - Thẻ "Học từ mới" nền `primary` (việc chính), thẻ "Ôn tập" nền trắng viền
    nhạt (việc phụ) → mắt biết bấm cái nào trước.
  - Bấm thẻ 1 → **`/learn` (danh sách chủ đề)**, không vào thẳng phiên học.
    Bấm thẻ 2 → phiên ôn tập.
  - Nhãn lấy từ `learnGoal.title` / `reviewGoal.title`. Hai entity này vẫn mang
    `completed`/`target` từ API (dùng ở nơi khác về sau) nhưng trang chủ không
    hiển thị.
- **Nhiệm vụ tháng**: một dải gọn nền `leafLight`, có `%` và mũi chevron.
- **Nhiệm vụ hằng ngày**: mỗi nhiệm vụ gồm hàng `icon + nhãn + x/y`, rồi thanh
  tiến độ **chiếm hết chiều ngang** ở dòng dưới. Tên nhiệm vụ tiếng Việt khá
  dài; nhồi thanh tiến độ cùng hàng với nhãn sẽ bóp nó còn vài chục pixel.
  Nhiệm vụ xong: gạch ngang mờ + dấu ✓ xanh.
- Kéo xuống để làm mới (`RefreshIndicator`).

### 5.2 Chụp / chọn ảnh — `/scan`

- Toàn màn hình camera, nút chụp tròn to ở giữa dưới.
- Bên trái nút chụp: mở thư viện ảnh. Bên phải: đổi camera trước/sau.
- Sau khi chụp: hiện ảnh xem trước + nút "Nhận diện" / "Chụp lại".
- Trong lúc gọi AI: overlay mờ + mascot + chữ "Đang đọc ảnh...". **Phải có nút
  Huỷ** vì gọi AI có thể lâu.

### 5.3 Kết quả nhận diện — `/scan/result`

*(ảnh 1)*

```
┌──────────────────────────────────────┐
│ ←  Kết quả nhận diện                 │
├──────────────────────────────────────┤
│ ╭──────────────────────────────────╮ │
│ │  [ảnh]        👁 Ẩn khung        │ │
│ │   ┌────┐ chair 0.98              │ │  khung + nhãn + độ tin cậy
│ │   │    │  ┌──────┐ laptop 0.92   │ │
│ │   └────┘  └──────┘               │ │
│ ╰──────────────────────────────────╯ │
│ Chọn chủ đề cho tất cả: [chọn chủ đề]│
│                                      │
│ ◯ chair  /tʃeə(r)/ – cái ghế     🔊 │
│    Chủ đề: [chọn chủ đề]             │
│ ◯ laptop /ˈlæptɒp/ – máy tính... 🔊 │
│    Chủ đề: [chọn chủ đề]             │
├──────────────────────────────────────┤
│ [ Lưu từ vựng ] [ Lưu và đăng tải ]  │  bottom bar cố định
└──────────────────────────────────────┘
```

Chi tiết:
- **Vùng ảnh**: ảnh gốc + các `BoundingBox` vẽ đè (`CustomPaint` hoặc `Stack` +
  `Positioned`). Nhãn dạng `từ  điểm` (ví dụ `chair 0.98`), nền tím/xanh mờ,
  chữ trắng nhỏ. Nút **"Ẩn khung"** (icon mắt) bật/tắt toàn bộ overlay.
- Toạ độ khung lưu theo **tỉ lệ 0..1** so với kích thước ảnh → tự co giãn theo
  khung hiển thị, không phụ thuộc kích thước gốc.
- Bấm vào một khung → cuộn tới và làm nổi thẻ từ tương ứng bên dưới (và ngược
  lại). Đây là điểm nhấn UX của màn hình này.
- **"Chọn chủ đề cho tất cả"**: đặt chủ đề cho mọi từ đang chọn trong một lần.
- **Danh sách từ**: `VocabCard.selectable`. Mặc định **chọn hết**; người dùng bỏ
  tick từ không muốn lưu.
- **Bottom bar**: 2 nút cạnh nhau.
  - `Lưu từ vựng` (primary) → lưu vào bộ từ cá nhân → về trang chủ + snackbar
    "Đã lưu N từ".
  - `Lưu và đăng tải` (secondary) → lưu **và** tạo bài đăng lên Cộng đồng.
  - Cả hai **disabled** khi không có từ nào được chọn.

### 5.4 Chọn chủ đề để học — `/learn`

Bước đệm giữa trang chủ và phiên học. Người học thấy mình đang dở chủ đề nào rồi
mới quyết định học tiếp cái gì, thay vì bị đẩy thẳng vào một phiên trộn lẫn.

```
┌──────────────────────────────────────┐
│ ←  Học từ mới                        │
├──────────────────────────────────────┤
│ ╭──────────────────────────────────╮ │
│ │ (43%)  Đã học 66/152 từ          │ │  thẻ tổng, gradient rừng
│ │        7 chủ đề                  │ │
│ │ [    Học trộn mọi chủ đề     ]   │ │
│ ╰──────────────────────────────────╯ │
│ Chọn chủ đề                          │
│ ╭──────────────────────────────────╮ │
│ │ (◔ ❤️) Sức khoẻ          22% ›   │ │
│ │        4/18 từ                   │ │
│ │        [Còn 14 từ mới]           │ │
│ ╰──────────────────────────────────╯ │
│ ╭──────────────────────────────────╮ │
│ │ (◉ 💚) Gia đình         100% ›   │ │  xong → vòng xanh lá
│ │        12/12 từ                  │ │
│ │        [Đã học xong]             │ │
│ ╰──────────────────────────────────╯ │
│ ...                                  │
└──────────────────────────────────────┘
```

Chi tiết:
- **Thẻ tổng** trên cùng: vòng tiến độ toàn bộ + tổng số từ + số chủ đề, kèm nút
  "Học trộn mọi chủ đề" cho người không muốn chọn.
- **Mỗi dòng chủ đề** (`TopicProgressTile`): vòng tiến độ có icon chủ đề ở giữa ·
  tên · `đã học/tổng` · chip trạng thái · `%` · chevron.
- Chủ đề **đã học xong** đổi vòng và chip sang xanh lá (`leaf`), phân biệt ngay
  với chủ đề đang học (xanh dương).
- Bấm một chủ đề → `/learn/session?topic=<id>`.
- Chưa có chủ đề nào → `EmptyState` mời chụp ảnh tạo bộ từ đầu tiên.

### 5.5 Học từ mới — `/learn/:sessionId`

AppBar: `← Học từ mới: vòng {n}` + thanh tiến độ vòng học mảnh ngay dưới.
Một phiên gồm nhiều **vòng**, mỗi vòng là một dạng bài. Hiện có 2 dạng:

#### Dạng A — Nối cặp từ *(ảnh 2)*

```
Nối các cặp từ

[ Fatigue    ]   [ Sự mệt mỏi ]
[ Cough      ]   [ Ho         ]
[ Grandfather]   [ Anh, em... ]
[ Brother    ]   [ Ông        ]

          [ Tiếp tục ]
```

- 2 cột: trái tiếng Anh, phải tiếng Việt. Thứ tự cột phải **xáo trộn**.
- Ô mặc định nền `successSoft`, chữ `textPrimary`, bo 12, cao ~48.
- Bấm ô trái → ô sáng lên (viền `primary`). Bấm ô phải:
  - **Đúng** → cả 2 ô chuyển `success` đậm rồi mờ dần / biến mất.
  - **Sai** → nháy đỏ (`danger`) ~300ms rồi bỏ chọn.
- Nút "Tiếp tục" **disabled** cho tới khi ghép hết cặp.

#### Dạng B — Trắc nghiệm *(ảnh 3)*

```
'Diet' có nghĩa là gì?

[ Chế độ ăn uống ]
[ Ông            ]
[ Trầm cảm       ]
[ Con trai       ]

     [ Kiểm tra ]   ← disabled khi chưa chọn
```

- Câu hỏi in đậm, từ tiếng Anh bọc trong dấu `'...'`.
- 4 đáp án dạng ô nền `neutral`, full width, bo 12, cách nhau 12.
- Chọn đáp án → viền + nền `primaryLight`; nút "Kiểm tra" bật.
- Bấm "Kiểm tra":
  - Đúng → ô xanh `success`, hiện dải phản hồi dưới đáy "Chính xác!" + nút
    "Tiếp tục".
  - Sai → ô chọn đỏ `danger`, ô đúng tô xanh, dải phản hồi hiện đáp án đúng.
- Từ trả lời sai được **đưa lại vào cuối hàng đợi** của phiên học.

#### Kết thúc phiên
Màn hình tổng kết: mascot chúc mừng, số từ đã học, XP nhận được, cá nhận được,
nút "Hoàn thành" về trang chủ.

### 5.6 Ôn tập (SRS) — `/review/:sessionId`

Dùng lại toàn bộ widget của mục 5.4, chỉ khác:
- Nguồn từ là các từ **đến hạn ôn** theo thuật toán SRS (spaced repetition).
  Mốc lặp lại: `0 → 1 → 3 → 7 → 21 → 60` ngày (`AppRewards.reviewIntervalDays`).
  Mốc đầu **0 ngày** để từ vừa học ôn lại được ngay trong ngày; trả lời sai thì
  về mốc đầu.
- Khi **không còn từ đến hạn** mà người dùng đã học ít nhất một từ: vẫn cho ôn
  lại, nguồn từ là toàn bộ từ đã học (xáo trộn). Lịch SRS là gợi ý, không phải
  cái khoá — chặn lại thì học xong một chủ đề là tab Ôn tập đứng im tới hôm sau.
  Chỉ khi **chưa học từ nào** thì nút mới bị vô hiệu hoá.
- Thẻ tổng kết ở đầu tab có 3 trạng thái: `N từ đến hạn ôn` →
  `Không còn từ nào đến hạn / Ôn lại từ đã học` → `Chưa có gì để ôn`.
- Thẻ mỗi bộ từ đo theo **số từ đã học** (khớp trang Học từ mới), phụ đề
  `Đã học 8/8 từ · thuộc 2`. Đo theo "đã thuộc" thì bộ từ vừa học xong vẫn hiện
  thanh rỗng, vì thuộc một từ cần ôn đúng vài lần trải qua ba tuần.
- AppBar: `← Ôn tập` + `còn N từ`.
- Sau mỗi từ, kết quả đúng/sai cập nhật khoảng lặp lại của từ đó ở tầng domain.

### 5.7 Cộng đồng — `/community`

3 tab trên cùng (`TabBar` chữ, gạch chân màu `primary`):
**Dòng thời gian · Nhóm học tập · Bảng xếp hạng**

#### Tab 1 — Dòng thời gian *(ảnh 4)*

Danh sách bài đăng, mỗi bài là một thẻ:
```
┌──────────────────────────────────────┐
│ 🦜 K64 - NEU              ⋮          │  avatar, tên, menu
│    5 tháng trước                     │
│ ╭──────────────────────────────────╮ │
│ │ [ảnh có khung nhận diện]         │ │  chip "chair - cái ghế 1.00"
│ ╰──────────────────────────────────╯ │
│ ◯ person  /pɜː.sən/ – người      🔊 │  VocabCard.compact
│    Chủ đề: [chọn chủ đề ˅]           │
│    [      Lưu từ vựng      ]         │  ← lưu từ của người khác về bộ mình
│ ❤️ 4      💬 0      🔖 0             │
└──────────────────────────────────────┘
```
- Hàng tương tác dưới cùng: **thích / bình luận / lưu bài**, mỗi cái icon + số.
  Đã thích → icon tô đỏ.
- Nút "Lưu từ vựng" trong bài cho phép **học từ của người khác** — đây là giá trị
  chính của feed.
- Cuộn vô hạn + kéo làm mới.

#### Tab 2 — Nhóm học tập *(ảnh 6)*

```
╭──────────────────────────────────────╮
│ 🦜🦜  neu                🔔 💬 ↩︎    │  gradient canopy → leaf
│       8 thành viên                   │
│       Trưởng nhóm: Hoang Duyen       │
╰──────────────────────────────────────╯
╭──────────────────────────────────────╮
│ Mốc hiện tại        ⏱ 7 ngày còn lại │
│ Chồi Non                             │
│   (🌱)       (?)         (?)         │  3 huy hiệu mốc
│  600 🌿    16000 🌿    30000 🌿      │
│ Chồi Non   Cây Vững    Đại Thụ       │
│                                      │
│           355                        │  số lớn
│      XP tích luỹ của nhóm            │
╰──────────────────────────────────────╯
```
- Header nhóm: gradient `canopy → leaf` (tán rừng), hoạ tiết lá mờ, avatar nhóm
  dạng cặp vẹt, 3 icon hành động (thông báo, chat nhóm, rời nhóm).
- Mốc: 3 chặng **Chồi Non → Cây Vững → Đại Thụ** (xem mục 2.6). Huy hiệu là cây
  lớn dần: mầm → cây con → đại thụ. **Chưa đạt hiện dạng xám + dấu `?`**; đạt
  rồi thì hiện màu và có hiệu ứng sáng nhẹ. Ngưỡng ghi bằng XP kèm icon lá.
- Chip đếm ngược thời gian còn lại của mùa/mốc.
- Nếu **chưa có nhóm** → `EmptyState` với 2 nút "Tạo nhóm" / "Tham gia nhóm".

#### Tab 3 — Bảng xếp hạng *(ảnh 5)*

```
Giải đấu
╭──────────────────────────────────────╮
│ Giải đấu tuần                        │
│  (🪺)      (?)      (?)              │  hạng giải; hạng hiện tại có viền xanh
│ Tán Thấp                             │  tên tầng rừng của hạng hiện tại
╰──────────────────────────────────────╯
┈┈┈ TOP AN TOÀN ┈┈┈                      ← nhãn ranh giới lên/xuống hạng
 4  🦜 Lê Hồng              154 🌿
 5  🦜 Lê Cường             129 🌿
 6  🦜 Bá Đức               122 🌿
```
- Huy hiệu giải đấu = **huy hiệu tổ vẹt theo tầng rừng** (thang 6 hạng ở mục
  2.6); tầng chưa mở hiện xám + dấu `?`.
- Hàng xếp hạng: số hạng, avatar, tên, XP + icon lá.
- Top 1–3: số hạng thay bằng huy chương vàng/bạc/đồng.
- **Hàng của chính mình**: nền `primaryLight`, chữ đậm, và **ghim (sticky)** khi
  cuộn ra khỏi màn hình.
- Các dải phân cách vùng: `TOP AN TOÀN` (giữ hạng), và nếu có: vùng lên hạng
  (xanh) / xuống hạng (đỏ nhạt).

### 5.8 Cửa hàng — `/shop`

*(ảnh 7)*

```
←  Cửa hàng                     💎 2  🌰 150

Vật phẩm của tôi
  (danh sách ngang các vật phẩm đang có + số lượng)

Mua ngay
┌──────────────────────────────────────┐
│ ⚡  Quả Tăng Tốc                      │
│     Nhân đôi XP nhận được trong 15'  │  🌰 150
├──────────────────────────────────────┤
│ 🛡  Khiên Vỏ Cây                     │
│     Giữ chuỗi streak khi nghỉ 1 ngày │  🌰 200
├──────────────────────────────────────┤
│ 🍯  Bình Mật Hoa                     │
│     Tăng 25% XP toàn app trong 24h   │  💎 2
├──────────────────────────────────────┤
│ 🦜  Sticker vẹt                      │
│     Dùng sticker trong chat & bình    │  💎 2
└──────────────────────────────────────┘
```
- Mỗi dòng: icon vật phẩm (trái) · tên đậm + mô tả `textSecondary` (giữa) ·
  giá + icon tiền (phải).
- Bấm dòng → bottom sheet xác nhận: icon lớn, tên, mô tả đầy đủ, giá, nút
  "Mua". Không đủ tiền → nút disabled + dòng chữ "Không đủ hạt/ngọc".
- Mua xong: hoạt ảnh ngắn + trừ số dư ở header ngay lập tức.

### 5.9 Trang cá nhân — `/profile`

*(ảnh 8)*

```
Trang cá nhân                        ⟳
╭──────────────────────────────────────╮
│      🦜   Công Tình             ⚙️   │
│   18        1          5             │
│ Ảnh đăng  Người      Đang            │
│           theo dõi   theo dõi        │
╰──────────────────────────────────────╯
Tổng quan
╭────────────────╮ ╭────────────────╮
│ 🪺 Hạng hiện...│ │ 🔥 Streak      │
│ Tán Thấp       │ │ 1              │
╰────────────────╯ ╰────────────────╯
╭────────────────╮ ╭────────────────╮
│ 🌳 Nhóm        │ │ 🌿 Kinh nghiệm │
│ Nhóm học...    │ │ 568            │
╰────────────────╯ ╰────────────────╯

Các bài đăng gần đây
[ảnh] [ảnh] [ảnh]
[ảnh] [ảnh] [ảnh]
```
- Thẻ đầu trang có **nền hoạ tiết lá cây mờ**, avatar tròn, tên đậm,
  bánh răng mở `/settings`, nút làm mới ở góc phải trên.
- 3 số liệu xã hội chia đều theo chiều ngang, bấm được (mở danh sách).
- **Tổng quan**: `GridView` 2×2, mỗi ô là `StatTile` (icon + nhãn nhỏ mờ + giá
  trị đậm). Nhãn dài thì cắt bằng `…`.
- **Bài đăng gần đây**: grid 3 cột, ảnh vuông, khoảng cách 2px; bấm mở bài đăng.
- Trang của người khác (`/user/:id`): thay bánh răng bằng nút
  "Theo dõi / Đang theo dõi".

---

## 6. Trạng thái & phản hồi (bắt buộc làm cho mọi màn hình)

| Trạng thái | Cách thể hiện |
|---|---|
| Đang tải | Skeleton xám bo góc theo đúng hình thẻ (không dùng spinner giữa trang, trừ overlay khi gọi AI) |
| Rỗng | `EmptyState`: mascot + 1 câu + nút hành động |
| Lỗi | `AppErrorView`: icon, câu ngắn tiếng Việt, nút "Thử lại" |
| Đang gọi AI | Overlay mờ + mascot động + "Đang đọc ảnh..." + nút Huỷ |
| Thành công | SnackBar nền xanh, bo góc, hiện 2s |
| Nút đang xử lý | Chữ thay bằng spinner trắng, nút giữ nguyên kích thước |

Mỗi trang được nuôi bằng `AsyncValue` từ Riverpod → map thẳng
`loading / error / data` sang 3 widget trên, không viết cờ boolean thủ công.

---

## 7. Chuyển động

Giữ ở mức tối thiểu, tất cả **200–300ms**, `Curves.easeOutCubic`:
- Chuyển trang: trượt ngang (mặc định của `go_router`).
- Bottom sheet chọn chủ đề: trượt lên.
- Ghép đúng cặp từ: phóng nhẹ 1.05 rồi mờ dần.
- Trả lời sai: rung ngang (shake) 300ms.
- Thanh tiến độ: `TweenAnimationBuilder` chạy từ giá trị cũ sang mới.
- Nhận XP/cá: số đếm tăng dần + icon nảy lên.

---

## 8. Khả năng tiếp cận & đáp ứng

- Vùng bấm tối thiểu **44×44** (nút loa, icon tương tác trong feed).
- Không truyền tải thông tin **chỉ bằng màu**: đúng/sai luôn kèm icon ✓/✗.
- Tôn trọng cỡ chữ hệ thống; dùng `Flexible`/`FittedBox` cho thẻ có số lớn.
- Ảnh trong feed dùng `AspectRatio` cố định để tránh giật layout khi tải.
- Chiều rộng thiết kế gốc **360–430dp**. Máy rộng hơn ~600dp: kẹp nội dung ở
  `maxWidth: 560`, căn giữa.
- Bọc nội dung trang trong `SafeArea`; bottom bar cố định phải cộng thêm
  `viewPadding.bottom`.

---

## 9. Thứ tự dựng (đề xuất)

1. `core/theme` (màu, text style, spacing, radius) + `core/router` khung rỗng.
2. `shared/widgets`: `PrimaryButton`, `LinearProgress`, `CurrencyPill`,
   `SectionHeader`, `EmptyState`, `AppLoading`, `AppErrorView`.
3. Vỏ điều hướng: `ShellRoute` + bottom nav + FAB camera (4 trang tạm rỗng).
4. **Trang chủ** (dữ liệu mock) — dựng được nhiều widget dùng chung nhất.
5. `VocabCard` → **Kết quả nhận diện** (mock danh sách từ + khung) →
   **Chụp ảnh**.
6. **Học từ mới**: dạng trắc nghiệm trước, rồi dạng nối cặp, rồi trang tổng kết.
7. **Ôn tập** (dùng lại widget của bước 6).
8. **Cộng đồng**: Dòng thời gian → Bảng xếp hạng → Nhóm học tập.
9. **Hồ sơ** → **Cửa hàng** → **Cài đặt**.

Mỗi bước dựng bằng dữ liệu **mock ở tầng `data`**, chưa cần API. Đúng theo
`ARCHITECTURE.md`: đổi mock → API về sau chỉ sửa tầng `data`, UI không đổi.

---

## 10. Vị trí file theo kiến trúc

| Màn hình | Đường dẫn |
|---|---|
| Trang chủ | `features/home/presentation/pages/home_page.dart` |
| Chụp ảnh | `features/image_scan/presentation/pages/scan_page.dart` |
| Kết quả nhận diện | `features/image_scan/presentation/pages/scan_result_page.dart` |
| Học từ mới | `features/quiz/presentation/pages/learn_session_page.dart` |
| Ôn tập | `features/flashcard/presentation/pages/review_session_page.dart` |
| Cộng đồng (3 tab) | `features/community/presentation/pages/` |
| Cửa hàng | `features/shop/presentation/pages/shop_page.dart` |
| Hồ sơ | `features/profile/presentation/pages/profile_page.dart` |

Feature **mới cần tạo** so với cây thư mục hiện tại: `image_scan`, `community`,
`shop`, `profile`. Mỗi feature vẫn theo đúng khuôn 3 tầng `data / domain /
presentation`.

---

## 11. Kho ảnh có sẵn

43 ảnh PNG hiện nằm ở `lib/images/`, đã đổi tên theo 5 nhóm tiền tố.

### 11.1 `mascot_*` — vẹt minh hoạ (10 ảnh)

| File | Nội dung | Dùng ở đâu |
|---|---|---|
| `mascot_camera.png` | Vẹt đeo tai nghe, cầm máy ảnh | Banner "Gửi ảnh học từ mới" (trang chủ) |
| `mascot_reading.png` | Vẹt đọc sách | Thẻ "Học từ mới" |
| `mascot_phone.png` | Vẹt cầm điện thoại | Thẻ "Ôn tập ngay" |
| `mascot_teacher.png` | Vẹt mũ tốt nghiệp + kính + thước | Đầu màn hình kiểm tra / quiz |
| `mascot_thumbs_up.png` | Vẹt nháy mắt, giơ ngón tay | Màn hình tổng kết phiên học |
| `mascot_trophy.png` | Vẹt bê cúp vàng | Thành tích, lên hạng |
| `mascot_quest.png` | Vẹt cầm bảng checklist | Mục "Nhiệm vụ" |
| `mascot_reward.png` | Vẹt nhảy ra từ hộp quà | Nhận thưởng, mở hộp |
| `mascot_reminder.png` | Vẹt cầm đồng hồ | Nhắc nhở học, thông báo streak |
| `mascot_favorite.png` | Vẹt với bóng thoại trái tim | Từ vựng yêu thích |

### 11.2 `ring_*` — vòng tiến độ (4 ảnh)

`ring/learn_new.png` · `ring/review.png` · `ring/test.png` · `ring/complete.png`

Đầu vẹt nằm trong vòng tiến độ tròn. Dùng cho 2 thẻ tiến độ ở trang chủ.

> ⚠️ **Số liệu bị nướng vào ảnh** (`9/15`, `1/30`, `5/15`, `10/20`) → không dùng
> trực tiếp được vì tiến độ là động. Cần **cắt lấy phần đầu vẹt**, rồi vẽ vòng
> tiến độ + số bằng Flutter (`CircularProgressIndicator` hoặc `CustomPaint`).
> Xem `ring_*` như ảnh tham chiếu thiết kế, không phải asset dùng ngay.

### 11.3 `icon_*` — icon điều hướng / hệ thống (9 ảnh)

| File | Hình | File | Hình |
|---|---|---|---|
| `icon_home.png` | Ngôi nhà | `icon_notification.png` | Cái chuông |
| `icon_study.png` | Quyển sách | `icon_message.png` | Bóng chat |
| `icon_quest.png` | Bảng checklist | `icon_settings.png` | Bánh răng |
| `icon_stats.png` | Cột biểu đồ | `icon_profile.png` | Người |
| `icon_achievement.png` | Huy chương | | |

Phong cách phẳng, đơn sắc xanh. Dùng cho bottom nav và các mục trong Cài đặt.

### 11.4 `sticker_*` — sticker cảm xúc (10 ảnh)

| File | Cảm xúc | File | Cảm xúc |
|---|---|---|---|
| `sticker_hello.png` | Chào (vẫy tay) | `sticker_sad.png` | Buồn (khóc) |
| `sticker_love.png` | Yêu thích (tim) | `sticker_cheer.png` | Cố lên! |
| `sticker_thinking.png` | Đang nghĩ | `sticker_tired.png` | Mệt quá (ngủ zZ) |
| `sticker_surprised.png` | Bất ngờ | `sticker_sorry.png` | Xin lỗi |
| `sticker_happy.png` | Vui vẻ | `sticker_awesome.png` | Tuyệt vời! |

Khớp với vật phẩm **"Sticker OK" / "Sticker yêu ngất ngày"** trong Cửa hàng →
dùng trong **chat nhóm** và **bình luận** ở Cộng đồng. Cần thêm một
`StickerPicker` (bottom sheet dạng grid) vào `shared/widgets/`.

### 11.5 `item_*` — vật phẩm & tiền tệ (10 ảnh)

| File | Hình | Ý nghĩa đề xuất |
|---|---|---|
| `item_diamond.png` | Kim cương xanh | **Ngọc** — tiền cứng (`coinGem`); nên đổi màu sang lục bảo |
| `item_coin.png` | Xu vàng có ngôi sao | Tạm dùng cho **Hạt** (`coinSeed`) — xem ghi chú dưới |
| `item_heart.png` | Trái tim đỏ | Sinh lực / lượt làm bài |
| `item_energy.png` | Tia sét vàng | **Quả Tăng Tốc** |
| `item_shield.png` | Khiên xanh | **Khiên Vỏ Cây** — giữ streak |
| `item_gift.png` | Hộp quà | **Bình Mật Hoa** + phần thưởng ngày |
| `item_ticket.png` | Vé xanh | Vé tham gia giải đấu |
| `item_calendar.png` | Lịch | Streak, chuỗi ngày học |
| `item_target.png` | Bia bắn | Mục tiêu ngày |
| `item_lock.png` | Ổ khoá vàng | Tầng rừng / nội dung chưa mở |

> Bộ `item_*` là **phong cách chung**, chưa mang chủ đề rừng. Về sau nên vẽ lại
> theo hướng thực vật: `item_coin` → **hạt dẻ / hạt hướng dương**, `item_energy`
> → **quả mọng đỏ**, `item_shield` → **khiên bằng vỏ cây / lá to**, `item_gift`
> → **bình mật hoa**. Trước mắt dùng tạm bộ hiện có, chỉ đổi **tên hiển thị**
> trong `app_labels.dart` — UI không cần sửa khi thay ảnh sau này.

### 11.6 Việc cần làm với kho ảnh

1. **Chuyển `lib/images/` → `assets/images/`.** Flutter quy ước asset nằm ngoài
   `lib/`; ảnh trong `lib/` không được đóng gói và không load được qua
   `AssetImage`. Sau khi chuyển, khai báo trong `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
2. **Tách thành thư mục con** cho gọn: `mascot/`, `icons/`, `stickers/`,
   `items/` (bỏ tiền tố khi đã có thư mục).
3. ~~Xoá phần chữ tiếng Việt bị nướng trong ảnh.~~ **✅ Đã làm.** Cả 43 ảnh đã
   được xoá caption, xoá nền (trắng + thẻ nền gradient) thành trong suốt, và
   crop sát vào hình. Script tại [tools/strip_assets.py](../tools/strip_assets.py),
   bản gốc giữ ở `assets/images_original/`.

   > **Còn sót:** 4 ảnh `ring/*` vẫn có số (`9/15`, `1/30`, `5/15`, `10/20`) vì
   > số nằm **bên trong** vòng tiến độ, xoá sẽ phá luôn vòng. Không sao — nhóm
   > này chỉ dùng làm ảnh tham chiếu thiết kế (xem 11.2).
4. **Xuất thêm bản `@2x` / `@3x`** (hoặc chuyển sang SVG cho nhóm `icon_*`) —
   các icon hiện chỉ ~100px, sẽ bị rỗ trên máy màn hình mật độ cao.
5. Sinh file hằng số `core/constants/app_assets.dart` để không viết chuỗi đường
   dẫn rải rác:
   ```dart
   abstract final class AppAssets {
     static const mascotCamera = 'assets/images/mascot/camera.png';
     static const iconHome     = 'assets/images/icons/home.png';
     // ...
   }
   ```
6. **Chưa có** (cần thiết kế thêm) — tất cả theo chủ đề rừng:
   - 6 huy hiệu hạng **tổ vẹt theo tầng rừng** (Thảm Rừng → Vượt Tán), mỗi cái
     2 trạng thái: đã mở (màu) / chưa mở (xám + `?`).
   - 3 huy hiệu mốc nhóm: **mầm → cây con → đại thụ**.
   - Icon **hạt** (`coinSeed`) và icon **lá** cho XP, tách khỏi `item_coin`.
   - Hoạ tiết nền lá cây / dây leo (`pattern/leaves.png`) để dùng ở header nhóm
     và thẻ hồ sơ.
   - Avatar nhóm dạng **cặp vẹt trên cành**.
