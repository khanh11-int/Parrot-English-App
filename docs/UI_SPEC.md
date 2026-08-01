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
| **Quả Tăng Tốc** | Nhân đôi XP trong 15 phút | 150 Hạt | `items/boost-fruit.png` |
| **Khiên Vỏ Cây** | Giữ chuỗi streak khi nghỉ 1 ngày | 200 Hạt | `items/bark-shield.png` |

Hai ảnh này vẽ riêng cho hai vật phẩm, **đặt tên trùng document id** trên
Firestore để dễ đối chiếu. Tên file phải là ASCII không dấu, không khoảng trắng —
đường dẫn asset có dấu bị lỗi mã hoá URL trên web.

> **Tác dụng chưa được cài đặt.** Mua thì trừ tiền và tăng số lượng thật, nhưng
> chưa có code nào đọc `users/{uid}/inventory` để áp hiệu ứng: XP vẫn cộng theo
> hằng số `AppRewards`, streak vẫn chỉ xét `lastActiveDate`. Muốn làm đúng thì
> cần thêm `activeUntil` vào inventory, nút "Sử dụng", và tính buff ở Cloud
> Functions (nếu tính ở client thì gian lận XP còn dễ hơn hiện tại).

---

## 3. Khung điều hướng

### 3.1 Bottom navigation (4 khe chia đều)

```
┌──────────────────────────────────────────────┐
│    🏠         📖         👥          👤       │
│ Trang chủ   Ôn tập    Cộng đồng    Hồ sơ     │
└──────────────────────────────────────────────┘
```

- Tab đang chọn: icon + nhãn màu `primary`; tab khác `textSecondary`.
- Thanh nav luôn hiện ở 4 tab gốc, **ẩn** trong các luồng học/ôn tập và các trang
  con push toàn màn hình (Cửa hàng, Cài đặt, Chat nhóm).
- Nhánh `main` có thêm **FAB camera** ở khe giữa (5 khe); nhánh `lite` không có
  camera nên bỏ FAB, 4 khe chia đều chiều ngang.

### 3.2 Sơ đồ route — `core/router/app_router.dart`

```
/                       ShellRoute (bottom nav)
├── /home               Trang chủ
├── /review             Ôn tập
├── /community          Cộng đồng   (2 tab con)
│   ├── Nhóm học tập
│   └── Bảng xếp hạng
└── /profile            Hồ sơ

/login /register        Xác thực                    (chưa đăng nhập)
/learn                  Chọn chủ đề để học          (fullscreen)
/learn/session?topic=   Phiên học từ mới            (fullscreen, ẩn nav)
/review-session?topic=  Phiên ôn tập SRS            (fullscreen, ẩn nav)
/shop                   Cửa hàng
/group-chat?id=         Chat nhóm
/settings               Cài đặt
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
│  nền primary        nền leafLight    │
│                                      │
│ Hôm nay                              │
│ ╭──────────────────────────────────╮ │
│ │ ○ Học 5 từ mới               0/5 │ │
│ │   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │ │  thanh full width
│ │ ─────────────────────────────────│ │
│ │ ○ Ôn tập 10 từ              0/10 │ │
│ │   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │ │
│ ╰──────────────────────────────────╯ │
│                                      │
│ Hành trình                           │
│ ╭──────────────────────────────────╮ │
│ │ 🌳 16/56 từ trong giáo trình 29%›│ │  nền leafLight, bấm → /learn
│ │ ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░  │ │
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
  - Thẻ "Học từ mới" nền `primary` chữ trắng (việc chính); thẻ "Ôn tập ngay" nền
    `leafLight`, **viền `leaf`**, chữ `canopy` (việc phụ) → mắt biết bấm cái nào
    trước, một thẻ tô đầy một thẻ viền.
  - Hai con số đo được, đừng đổi bừa:
    - Chữ phải là `canopy` (6.90:1 trên `leafLight`). `leafDark` chỉ đạt
      **4.59:1** — vừa qua ngưỡng AA cho chữ thường mà không còn dư, và nhãn ở
      đây là 14px w600 nên đọc ra rất nhạt.
    - Viền phải **thấy được**. Nền thẻ `leafLight` (#E7F6E3) gần trùng nền trang
      (#EAF7E6) — chênh **1.01:1** — nên viền cùng màu nền thẻ làm thẻ tan hẳn
      vào trang, không còn ra hình một thẻ bấm được.
  - Bấm thẻ 1 → **`/learn`** (danh sách chủ đề), bấm thẻ 2 → **tab `/review`**.
    Cả hai đều dừng ở trang chọn, không nhảy thẳng vào phiên: tab Ôn tập mới cho
    thấy bộ nào đến hạn và cho ôn riêng từng chủ đề (5.6).
  - Nhãn là hằng số trong `AppLabels`, không lấy từ dữ liệu — đây là tên hai chỗ
    đi tới, không phải số liệu. Nhãn thẻ là `Ôn tập ngay`, khác nhãn tab
    `Ôn tập`, để không có hai chữ giống nhau trên cùng màn hình.
- **Hôm nay**: mỗi nhiệm vụ gồm hàng `icon + nhãn + x/y`, rồi thanh tiến độ
  **chiếm hết chiều ngang** ở dòng dưới. Tên nhiệm vụ tiếng Việt khá dài; nhồi
  thanh tiến độ cùng hàng với nhãn sẽ bóp nó còn vài chục pixel. Nhiệm vụ xong:
  gạch ngang mờ + dấu ✓ xanh. Thẻ **không bấm được** — trang chi tiết nhiệm vụ
  chưa có, nên không bọc `InkWell` để khỏi hiện hiệu ứng chạm rồi không đi đâu.
- **Hành trình**: tiến độ cả giáo trình dạng `16/56 từ` + thanh + `%`, nền
  `leafLight`, bấm → `/learn`.
  - Thay cho dải một dòng cũ "📅 Nhiệm vụ tháng Chín 15% ›": hai con số bị nhồi
    vào **chuỗi tiêu đề** của một `Quest` ("Học hết 56 từ trong giáo trình") nên
    UI không tách ra được, chỉ hiện được `%`. Nay là hai field riêng
    (`learnedWordCount` / `totalWordCount`).
  - Chevron cũ dẫn tới trang chi tiết chưa tồn tại; nay dẫn sang `/learn`.
  - Nền thanh tiến độ là **trắng** chứ không phải `neutral` xám — trên `leafLight`
    thì xám gần như trùng màu, không thấy phần chưa đạt.
- Hai mục tách tên riêng thay vì gộp dưới một chữ "Nhiệm vụ": việc hôm nay và
  tiến độ dài hạn là hai chuyện, đọc theo hai kiểu khác nhau.
- Kéo xuống để làm mới (`RefreshIndicator`).

> Mục 5.2 (chụp / chọn ảnh) và 5.3 (kết quả nhận diện) **không có ở nhánh
> `lite`** — xem nhánh `main` nếu cần. Số mục giữ nguyên để không phải đánh số
> lại toàn bộ tài liệu.

### 5.4 Chọn chủ đề để học — `/learn`

Bước đệm giữa trang chủ và phiên học. Người học thấy mình đang dở chủ đề nào rồi
mới quyết định học tiếp cái gì, thay vì bị đẩy thẳng vào một phiên trộn lẫn.

```
┌──────────────────────────────────────┐
│ ←  Học từ mới                        │
├──────────────────────────────────────┤
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
- **Không có thẻ tổng.** Từng có một thẻ gradient "Đã học 66/152 từ · 7 chủ đề"
  kèm nút "Học trộn mọi chủ đề" ở đầu trang; đã bỏ vì trang này chỉ để chọn chủ
  đề, thẻ đó đẩy danh sách xuống dưới màn hình mà không giúp gì cho việc chọn.
  Tiến độ tổng đã có ở trang chủ.
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

### 5.6 Tab Ôn tập — `/review`

```
┌──────────────────────────────────────┐
│ ╭──────────────────────────────────╮ │
│ │ 5 từ đến hạn ôn            🦜    │ │  gradient rừng
│ │ Ôn ngay để giữ chuỗi streak      │ │
│ │ [ Ôn tập ngay ]                  │ │
│ ╰──────────────────────────────────╯ │
│ Bộ từ của bạn                        │
│ ╭──────────────────────────────────╮ │
│ │ Sức khoẻ      [5 đến hạn]     ›  │ │  bấm → ôn riêng chủ đề này
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░ │ │
│ │ Đã học 8/8 từ · thuộc 2          │ │
│ ╰──────────────────────────────────╯ │
│ ╭──────────────────────────────────╮ │
│ │ Gia đình                      ›  │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░ │ │
│ │ Đã học 6/8 từ · đến hạn mai      │ │
│ ╰──────────────────────────────────╯ │
│   ⊕ Còn 5 chủ đề chưa học        ›   │  → /learn
└──────────────────────────────────────┘
```

**Chỉ liệt kê bộ từ đã học.** Chủ đề chưa chạm tới thì không ôn được; để chúng
trong danh sách chỉ đẩy phần dùng được xuống dưới màn hình (người dùng phải cuộn
qua 5 thẻ `Đã học 0/8` với thanh rỗng). Chúng gom thành **một dòng** ở cuối trang
dẫn sang `/learn`.

Thứ tự: **có từ đến hạn lên trước** (việc cần làm hôm nay), rồi tới bộ đã học
nhiều hơn — bộ đang học dở đáng ôn hơn bộ mới chạm một hai từ.

Thẻ tổng kết có 3 trạng thái, mỗi trạng thái nói rõ **việc tiếp theo**:

| Điều kiện | Tiêu đề | Phụ đề | Nút |
|---|---|---|---|
| còn từ đến hạn | `N từ đến hạn ôn` | giữ streak | `Ôn tập ngay` |
| đã học, chưa tới hạn | `Không còn từ nào đến hạn` | `Đến hạn tiếp mai · ôn lại luôn cũng được` | `Ôn lại từ đã học` |
| chưa học gì | `Chưa có gì để ôn` | dẫn sang Học từ mới | vô hiệu hoá |

Thẻ bộ từ:
- **Bấm được** → phiên ôn riêng chủ đề đó (`/review-session?topic=<id>`). Nút lớn
  ở thẻ tổng kết là ôn **trộn** mọi chủ đề.
- Thanh đo theo **số từ đã học**, khớp trang Học từ mới. Đo theo "đã thuộc" thì bộ
  từ vừa học xong vẫn hiện thanh rỗng, vì thuộc một từ cần ôn đúng vài lần trải
  qua ba tuần.
- Phụ đề nói **một** thông tin hữu ích, không liệt kê mọi con số: có từ đã thuộc
  thì `· thuộc N`, chưa có thì `· đến hạn mai`. Bỏ `thuộc 0` vì suốt mấy tuần đầu
  nó chỉ là con số 0 lặp lại ở mọi thẻ.
- Mốc thời gian diễn đạt theo lời người nói: `hôm nay` / `mai` / `3 ngày nữa`
  (`describeDueIn`), đếm theo **ngày lịch** chứ không theo số giờ chênh lệch — 20h
  hôm nay tới 8h mai chỉ cách 12 tiếng nhưng người học vẫn gọi đó là "mai".

### 5.6b Phiên ôn tập — `/review-session`

Dùng lại toàn bộ widget của mục 5.5, chỉ khác:
- Nguồn từ là các từ **đến hạn ôn** theo SRS (spaced repetition). Mốc lặp lại:
  `0 → 1 → 3 → 7 → 21 → 60` ngày (`AppRewards.reviewIntervalDays`). Mốc đầu
  **0 ngày** để từ vừa học ôn lại được ngay trong ngày; trả lời sai thì về mốc đầu.
  Từ có khoảng lặp lại ≥ 21 ngày coi là **đã thuộc**.
- Khi **không còn từ đến hạn** mà người dùng đã học ít nhất một từ: vẫn cho ôn
  lại, nguồn từ là toàn bộ từ đã học (xáo trộn). Lịch SRS là gợi ý, không phải
  cái khoá — chặn lại thì học xong một chủ đề là tab Ôn tập đứng im tới hôm sau.
- `?topic=<id>` giới hạn trong một chủ đề. Lọc "đến hạn" ngay trong Dart thay vì
  thêm điều kiện vào truy vấn: `where topicId == X` **và** `where dueAt <= now`
  cần composite index, mà một chủ đề chỉ vài chục từ.
- AppBar: `← Ôn tập` + `còn N từ`.
- Sau mỗi vòng, kết quả đúng/sai cập nhật khoảng lặp lại của từ đó. Lần đầu gặp
  từ mới ghi nội dung (`toCreateMap`); các lần sau **chỉ** ghi lịch ôn
  (`toUpdateMap`) — phiên ôn trộn chủ đề không biết nội dung gốc nên ghi lại là
  ghi chuỗi rỗng lên dữ liệu đúng.

### 5.7 Cộng đồng — `/community`

2 tab trên cùng (`TabBar` chữ, gạch chân màu `primary`):
**Nhóm học tập · Bảng xếp hạng**

> Nhánh `main` có thêm tab **Dòng thời gian** ở đầu. Nhánh `lite` không có nên
> Cộng đồng chỉ còn 2 tab; số hiệu "Tab 2 / Tab 3" giữ nguyên để khớp với
> `main`.

#### Tab 2 — Nhóm học tập *(ảnh 6)*

```
╭──────────────────────────────────────╮
│ 🦜🦜  neu                   💬 ↩︎    │  gradient canopy → leaf
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
  dạng cặp vẹt, **2 icon hành động**: chat nhóm và rời nhóm.
  - Từng có icon 🔔 thông báo nhưng `onPressed: null` vì chưa làm — đã bỏ. Mọi
    nút trên header giờ đều bấm được, nên `_GroupActionIcon.onPressed` là tham số
    **bắt buộc**, không cho lọt thêm nút chết vào.
- Mốc: 3 chặng **Chồi Non → Cây Vững → Đại Thụ** (xem mục 2.6). Huy hiệu là cây
  lớn dần: mầm → cây con → đại thụ. **Chưa đạt hiện dạng xám + dấu `?`**; đạt
  rồi thì hiện màu và có hiệu ứng sáng nhẹ. Ngưỡng ghi bằng XP kèm icon lá.
- Chip đếm ngược thời gian còn lại của mùa/mốc.

**Chưa ở nhóm nào** (mới vào app, hoặc vừa rời nhóm):

```
╭──────────────────────────────────────╮
│ Bạn chưa ở nhóm nào             🦜   │  gradient canopy → leaf
│ Học cùng nhóm để cùng trồng cây      │
│ [ Tạo nhóm mới ]                     │
╰──────────────────────────────────────╯
Nhóm có thể tham gia
╭──────────────────────────────────────╮
│ (👥) neu                 [Tham gia]  │
│      8 thành viên · Trưởng nhóm ...  │
╰──────────────────────────────────────╯
╭──────────────────────────────────────╮
│ (👥) K64 - NEU           [Tham gia]  │
│      12 thành viên · Trưởng nhóm ... │
╰──────────────────────────────────────╯
```

- Danh sách nhóm hiện **ngay trên trang**, không nằm trong bottom sheet. Trước đây
  chỗ này là `EmptyState` với 2 nút "Tạo nhóm" / "Tham gia nhóm", danh sách nhóm
  phải bấm nút thứ hai mới thấy — người vừa rời nhóm mở tab lên chỉ thấy một
  trang trống, không biết có nhóm nào để vào hay không.
- Nút **"Tham gia" nằm trên từng thẻ**, không phải cả thẻ bấm được: vào nhóm là
  việc khó lùi (rời ra rồi vào lại là mất chỗ trong bảng xếp hạng nhóm) nên phải
  cố ý bấm, không chạm nhầm.
- Kéo xuống để làm mới danh sách.
- Skeleton của danh sách này **không cuộn** (`Column` các `SkeletonBox`): nó nằm
  trong `ListView` của trang, dùng skeleton mặc định dạng `ListView` sẽ thành hai
  vùng cuộn lồng nhau và ném "unbounded height".

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
└──────────────────────────────────────┘
```

Cửa hàng có **2 vật phẩm** (xem bảng ở mục 2.6). Ba món cũ — Bình Mật Hoa,
Sticker vẹt, Vé Giải Đấu — đã xoá khỏi `shopItems` trên Firestore.
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
```
- Thẻ đầu trang có **nền hoạ tiết lá cây mờ**, avatar tròn, tên đậm,
  bánh răng mở `/settings`, nút làm mới ở góc phải trên.
- Avatar là **huy hiệu hạng**, đổi theo XP — xem `RankAvatar` ở mục 11.2.
- **Tổng quan**: `GridView` 2×2, mỗi ô là `StatTile` (icon + nhãn nhỏ mờ + giá
  trị đậm). Nhãn dài thì cắt bằng `…`.
- **Không có mục "Các bài đăng gần đây"**: nhánh này không có dòng thời gian nên
  không có bài đăng nào để hiện. Lưới cũ chỉ vẽ N ô xám rỗng theo
  `recentPostCount`, mà con số đó luôn là `0`.
- Trang của người khác (`/user/:id`) chưa dựng.

> **Đã bỏ cả ba số liệu xã hội** (`Ảnh đăng`, `Người theo dõi`, `Đang theo
> dõi`). Cả ba luôn là `0`: không có dòng thời gian nên không có bài đăng, và
> không có chỗ nào để theo dõi ai — chưa có trang cá nhân người khác, chưa có nút
> Theo dõi. Ba con số 0 xếp hàng ngang không nói lên điều gì.
>
> Dựng lại khi có tính năng thật. Field trong Firestore cũng đã bỏ khỏi `toMap`
> nên document mới không ghi `postCount` / `followerCount` / `followingCount`.

### 5.9b Cài đặt — `/settings`

Chỉ có **một thẻ**, ba dòng:

| Dòng | Nội dung |
|---|---|
| **Tên hiển thị** | tên hiện tại, bấm mở hộp thoại sửa. Chưa đặt thì ghi thẳng "Chưa đặt — bấm để đặt tên" |
| **Email** | chỉ đọc |
| **Đăng xuất** | có bước xác nhận, vì đăng xuất là việc khó lùi |

**Tên hiển thị là nguồn sự thật duy nhất của tên người học.** Đường đi:

```
Cài đặt → AuthRepository.updateDisplayName()   (ghi vào Firebase Auth)
        → authStateChanges() phát lại           (dùng userChanges(), không phải
                                                 authStateChanges() của SDK)
        → profileBootstrapProvider.ensureProfile()
                                                (đồng bộ xuống users/{uid}.name)
        → userDataRevision.bump()
        → trang chủ · Hồ sơ · Bảng xếp hạng tải lại
```

Vì sao phải qua Firestore: **bảng xếp hạng đọc `users/{uid}.name`** của người
khác, không đọc được Firebase Auth của họ. Vì sao phải là `userChanges()`:
`authStateChanges()` của SDK **không** phát khi hồ sơ đổi, nên `signUp` gọi
`updateDisplayName` sau khi tài khoản đã tạo thì không chỗ nào biết để đồng bộ —
đó chính là lý do tài khoản cũ hiện phần trước `@` của email thay vì tên.

> Trước đây trên nó là danh sách 6 mục (Thông báo · Tin nhắn · Thống kê học tập ·
> Thành tích · Nhiệm vụ · Hồ sơ của tôi). **Cả 6 đều `onTap: null`** vì chưa trang
> nào tồn tại — một danh sách chỉ để ngắm, có mũi chevron mời bấm nhưng bấm không
> đi đâu. Đã bỏ hẳn. Icon vẫn còn ở `assets/images/icons/`; dựng lại từng mục khi
> trang tương ứng có thật.

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
## 11. Kho ảnh

**85 ảnh PNG** ở `assets/images/`, chia 7 thư mục theo vai trò. Đường dẫn khai
báo tập trung ở [`core/constants/app_assets.dart`](../lib/core/constants/app_assets.dart)
— mọi hằng số ở đó đều trỏ tới file có thật, và mọi file đều có hằng số trỏ tới
(không có ảnh mồ côi).

| Thư mục | Số ảnh | Nội dung | Nền |
|---|---|---|---|
| `mascot/` | 30 | Vẹt trong một dáng hoặc kèm một vật phẩm | phần lớn còn nền |
| `topics/` | 13 | 13 chủ đề tiếng Anh | phần lớn còn nền |
| `items/` | 15 | Đồ vật phẳng: tiền tệ, vật phẩm cửa hàng, sách, cúp, vé, chuông | trong suốt |
| `stickers/` | 10 | Sticker cảm xúc, dùng cho `StickerPicker` | trong suốt |
| `icons/` | 10 | Icon điều hướng / hệ thống, **đơn sắc phẳng** | trong suốt |
| `ranks/` | 6 | Huy hiệu 6 hạng tầng rừng | còn nền |
| `milestones/` | 3 | Cây rừng cho 3 mốc nhóm — **chưa nối vào UI** | trong suốt |
| `decor/` | 2 | Hoạ tiết cây rừng cho thẻ lớn — **chưa nối vào UI** | trong suốt |
| `ring/` | 1 | Vòng tiến độ — chỉ là ảnh tham chiếu thiết kế | còn nền |

### 11.1 `icons/` phải là ảnh phẳng đơn sắc

`AppBottomNav` nhuộm icon bằng `BlendMode.srcIn` để đánh dấu tab đang chọn. Phép
nhuộm đó **thay toàn bộ màu** của ảnh, nên chỉ đúng với ảnh phẳng một màu. Đưa
ảnh nhiều màu (ví dụ bản có mascot) vào `icons/` sẽ khiến nó thành một khối màu
đặc, mất hết chi tiết.

Vì vậy bộ ảnh mới có sẵn bản "mascot + vật phẩm" cho home / study / message /
profile / settings / statistics, nhưng chúng nằm ở `mascot/` chứ **không** thay
icon điều hướng. Dùng chúng cho trạng thái rỗng, đầu mục, thẻ minh hoạ.

### 11.2 `ranks/` — huy hiệu 6 hạng

`level-1.png` … `level-6.png` khớp với [`ForestRank`](../lib/core/constants/app_labels.dart):
vẹt nở từ trứng (Thảm Rừng) rồi lớn dần tới lúc đội vương miện (Vượt Tán). Lấy
bằng `AppAssets.rankBadge(rank.index)`.

**Avatar người học chính là huy hiệu hạng.** `RankAvatar` chọn ảnh theo
`ForestRank.fromExperience(xp)`, nên lên hạng là avatar đổi theo — ở Hồ sơ và ở
mọi hàng của Bảng xếp hạng. Người học nhìn avatar là biết mình đang ở tầng nào,
không phải mở Hồ sơ đọc chữ.

Nếu người dùng tự đặt ảnh (`users/{uid}.avatarUrl` khác rỗng) thì ảnh đó được ưu
tiên. **Rỗng là chuyện bình thường** — tài khoản mới luôn rỗng — nên không được
đưa thẳng chuỗi rỗng vào `AppImage`, làm vậy sẽ hiện ô xám vỡ ảnh.

> Huy hiệu mốc **nhóm** (Chồi Non / Cây Vững / Đại Thụ) vẫn dùng icon vật phẩm
> tạm (`itemTarget` / `itemLock`). Ảnh cây đã có ở `milestones/` và hằng số
> `AppAssets.milestoneBadge()` đã sẵn, nhưng **cố ý chưa nối vào UI** — đã thử một
> lần rồi quay lại giao diện cũ.

### 11.3 `topics/` rộng hơn số chủ đề đang có

13 ảnh chủ đề, trong khi Firestore chỉ có 7 chủ đề (`health`, `family`,
`furniture`, `office`, `technology`, `food`, `school`). Ba ảnh khớp trực tiếp
(`technology`, `school`, `food-drinks`); phần còn lại để dành cho lúc mở thêm chủ
đề. `TopicDocument.iconAssetFor` hiện vẫn map sang `items/*` — đổi sang
`topics/*` là một việc riêng.

### 11.4 Việc còn lại với kho ảnh

1. **Xoá nền cho ảnh mới.** Bộ cũ đã được [tools/strip_assets.py](../tools/strip_assets.py)
   xoá caption + xoá nền + crop sát hình. Bộ mới **chưa qua bước này** nên nhiều
   ảnh còn khung nền bo góc hoặc nền tròn — đặt cạnh ảnh cũ sẽ thấy lệch.
2. **Nối `ranks/` vào Hồ sơ và Bảng xếp hạng** thay icon vật phẩm tạm.
3. **Nối `topics/` vào `TopicDocument.iconAssetFor`** khi mở thêm chủ đề.
4. **Xuất bản `@2x` / `@3x`** (hoặc SVG cho `icons/`) — ảnh hiện chỉ ~100–300px,
   sẽ rỗ trên màn hình mật độ cao.
5. **Chưa có:** 3 huy hiệu mốc nhóm (mầm → cây con → đại thụ), icon **hạt** và
   icon **lá** riêng cho XP, hoạ tiết nền lá `pattern/leaves.png`, avatar nhóm
   dạng cặp vẹt trên cành.
