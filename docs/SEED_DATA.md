# Dữ liệu mẫu cần nhập vào Firestore

Hai collection `topics` và `shopItems` là **dữ liệu dùng chung, chỉ đọc** —
[firestore.rules](../firestore.rules) chặn client ghi vào chúng, nên phải nhập qua
Firebase Console.

Mở: https://console.firebase.google.com/project/parrot-english-app/firestore

> **Document ID phải đúng chính xác.** App dùng id để tra ảnh minh hoạ trong
> `assets/images/` (xem `TopicDocument.iconAssetFor` và
> `ShopItemDocument.iconAssetFor`). Sai id thì vẫn chạy nhưng hiện ảnh mặc định.

---

## 1. Collection `topics` — 7 document

Mỗi document có **3 field**:

| Field | Kiểu | Ý nghĩa |
|---|---|---|
| `name` | string | Tên hiển thị |
| `wordCount` | **int** | Tổng số từ trong giáo trình của chủ đề |
| `order` | **int** | Thứ tự hiển thị trong danh sách |

Số từ đã học **không** nằm ở đây — nó là dữ liệu riêng từng người, ở
`users/{uid}/topicProgress/{topicId}`, do app tự ghi khi người dùng học.

| Document ID | `name` | `wordCount` | `order` |
|---|---|---|---|
| `health` | Sức khoẻ | 8 | 1 |
| `family` | Gia đình | 8 | 2 |
| `furniture` | Đồ nội thất | 8 | 3 |
| `office` | Văn phòng | 8 | 4 |
| `technology` | Công nghệ | 8 | 5 |
| `food` | Đồ ăn thức uống | 8 | 6 |
| `school` | Trường học | 8 | 7 |

> `wordCount` **phải khớp** số document thật trong `topics/{id}/words`, nếu không
> tiến độ sẽ sai (ví dụ hiện `8/24` dù chủ đề chỉ có 8 từ).

### 1.1 Subcollection `topics/{id}/words` — giáo trình từ vựng

Đây là **bộ từ để học**, dùng chung cho mọi người. Mỗi document 4 field:

| Field | Kiểu | Ví dụ |
|---|---|---|
| `english` | string | `fever` |
| `phonetic` | string | `/ˈfiːvə/` |
| `vietnamese` | string | `cơn sốt` |
| `order` | **int** | `1` |

Document ID = chính chữ tiếng Anh (`fever`, `cough`...).

Hiện đã seed **56 từ** (8 từ × 7 chủ đề) bằng script. Muốn thêm từ thì sửa
`WORDS` trong script seed rồi chạy lại — script dùng `PATCH` nên chạy lại không
tạo bản trùng.

⚠️ Rules **chặn client ghi** vào `topics/{id}/words` — đây là giáo trình, không
phải dữ liệu người dùng. Thêm từ phải qua Console hoặc script (mở rules tạm).

## 2. Collection `shopItems` — 5 document

Mỗi document có **5 field**:

| Field | Kiểu | Ý nghĩa |
|---|---|---|
| `name` | string | Tên vật phẩm |
| `description` | string | Mô tả tác dụng |
| `price` | **int** | Giá |
| `currency` | string | `seed` (hạt) hoặc `gem` (ngọc) — **viết đúng chữ thường** |
| `order` | **int** | Thứ tự hiển thị |

| Document ID | `name` | `description` | `price` | `currency` | `order` |
|---|---|---|---|---|---|
| `boost-fruit` | Quả Tăng Tốc | Nhân đôi XP nhận được trong 15 phút | 150 | `seed` | 1 |
| `bark-shield` | Khiên Vỏ Cây | Giữ chuỗi streak khi nghỉ 1 ngày | 200 | `seed` | 2 |
| `nectar-bottle` | Bình Mật Hoa | Tăng 25% XP toàn app trong 24 giờ | 2 | `gem` | 3 |
| `sticker-pack` | Sticker vẹt | Dùng sticker trong chat nhóm & bình luận | 2 | `gem` | 4 |
| `league-ticket` | Vé Giải Đấu | Tham gia giải đấu tuần ngoài lượt thường | 300 | `seed` | 5 |

---

## Cách nhập tay trên Console (cho mục 1 và 2)

**Document đầu tiên của mỗi collection:**

1. Bấm **Start collection**
2. Collection ID: `topics` → **Next**
3. Document ID: `health` (gõ tay, **đừng** bấm *Auto-ID*)
4. Thêm 3 field, chú ý chọn đúng **Type**: `string` cho chữ, **`int`** cho số
   (Console tách số thành `int` và `double`; ở đây không có số thập phân nào)
5. **Save**

**Các document sau:**

1. Chọn collection `topics` ở cột giữa
2. Bấm **+ Add document**
3. Lặp lại bước 3–5

> Mẹo đỡ mỏi tay: nhập xong `health`, bấm dấu **⋮** bên cạnh document → chọn
> **Duplicate document**, đặt id mới rồi sửa 3 giá trị. Nhanh hơn tạo lại field
> từ đầu.

---

## 3. Dữ liệu mẫu Cộng đồng

Phần này **đã nạp bằng script**, không nhập tay. Ghi lại ở đây để biết trong DB
đang có gì và nạp lại thế nào.

### 3.1 `users` — 7 người học mẫu

Id bắt đầu bằng `sample-`, **không có tài khoản Authentication tương ứng** —
chỉ là document trong Firestore để bảng xếp hạng và nhóm có số liệu. Muốn dọn
thì xoá 7 document đó.

| Tên | XP | Nhóm |
|---|---|---|
| Minh Anh | 3.120 | `k64-neu` |
| Hoàng Duyên | 2.640 | `neu` |
| Thu Hà | 1.980 | `neu` |
| Lê Hồng | 1.540 | `neu` |
| Lê Cường | 1.290 | `clb-english` |
| Bá Đức | 820 | `k64-neu` |
| Quốc Bảo | 340 | `k64-neu` |

### 3.2 `groups` — 3 nhóm

| Document ID | `name` | `leaderName` | Thành viên | XP nhóm |
|---|---|---|---|---|
| `neu` | neu | Hoàng Duyên | 4 (gồm bạn) | 6.160 |
| `k64-neu` | K64 - NEU | Minh Anh | 3 | 4.280 |
| `clb-english` | CLB English Zone | Lê Cường | 1 | 1.290 |

Field lưu trong document: `name`, `leaderId`, `leaderName`, `daysRemaining`.

> **Số thành viên và XP nhóm KHÔNG lưu trong document.** App tính bằng aggregate
> `count()` và `sum('experience')` trên `users` where `groupId == <id>`.
>
> Việc này cần **composite index** `users(groupId, experience)` — Firestore đòi
> index cho `sum`/`average` khi có filter, riêng `count()` thì không. Index đã
> khai báo trong `firestore.indexes.json`, deploy bằng
> `firebase deploy --only firestore:indexes`.
>
> Lý do: nếu lưu sẵn hai con số đó thì mỗi lần có người vào/rời nhóm đều phải
> cho họ ghi vào document nhóm — mở quyền đó ra là ai cũng sửa được XP cả nhóm.
> Với cách hiện tại, **vào/rời nhóm chỉ ghi `users/{uid}.groupId`** của chính
> mình.

### 3.3 `groups/neu/messages` — 8 tin nhắn chat

Một đoạn hội thoại có cả chữ và sticker, `createdAt` giãn từ 3 giờ trước đến 45
phút trước.

| Field | Kiểu | Ghi chú |
|---|---|---|
| `authorId` | string | Phải đúng uid người gửi — rules chặn mạo danh |
| `authorName` | string | Tên hiển thị |
| `text` | string | Có khi là tin chữ |
| `stickerAsset` | string | Có khi là tin sticker, ví dụ `assets/images/stickers/awesome.png` |
| `createdAt` | timestamp | Dùng để sắp thứ tự |

Mỗi tin có **`text` hoặc `stickerAsset`**, không có cả hai.

### 3.4 `posts/{postId}/comments` — 7 bình luận

Rải trên 4 bài đăng, cùng hình dạng field như tin nhắn chat (app dùng chung một
kiểu `ChatMessage` cho cả hai).

| Bài đăng | Số bình luận |
|---|---|
| `post-desk-setup` | 3 |
| `post-backpack` | 2 (1 sticker) |
| `post-coffee` | 1 |
| `post-library` | 1 |

`commentCount` trên document bài đăng đã được đồng bộ khớp với số bình luận
thật. Khi người dùng bình luận trong app, con số này tự tăng trong cùng batch
với việc ghi bình luận.

### 3.5 Nạp lại dữ liệu Cộng đồng

Rules **chặn client** ghi bài đăng đứng tên người khác, ghi hồ sơ người khác, và
xoá tin nhắn. Nên script seed phải chạy theo 3 bước:

1. Deploy một bộ rules tạm nới lỏng (để ngoài repo, không thể deploy nhầm)
2. Chạy script ghi dữ liệu
3. **Deploy lại `firestore.rules`** rồi kiểm lại bộ 8 phép truy cập trái phép

Cửa sổ nới lỏng khoảng 20 giây. Script dùng `PATCH` nên chạy lại nhiều lần cho
ra cùng kết quả.

---

## Cho mình một ít tiền để thử Cửa hàng

Cửa hàng đọc `seeds` và `gems` từ `users/{uid}` của bạn, mà tài khoản mới có
`seeds = 0` nên không mua được gì.

Để thử tính năng mua:

1. Vào collection `users`, mở document của bạn (id là `uid`, xem ở
   Authentication → Users)
2. Sửa `seeds` thành `1000`, `gems` thành `50`
3. Mở Cửa hàng trong app → bấm mua

> Việc client sửa được `seeds`/`gems` chính là lỗ hổng đã ghi trong
> [PLAN.md](PLAN.md): rules cho chủ sở hữu tự ghi hồ sơ của mình nên **XP và
> tiền gian lận được**. Chỉ khắc phục được bằng Cloud Functions (cần gói Blaze).

---

## Kiểm tra sau khi nhập

Chạy app rồi:

| Màn hình | Phải thấy |
|---|---|
| **Học từ mới** | 7 chủ đề, tiến độ `0/8`, tổng `Đã học 0/56 từ` |
| Bấm một chủ đề | Bài tập với **đúng từ của chủ đề đó** |
| **Cửa hàng** | 5 vật phẩm, đúng giá, icon đúng |
| **Hồ sơ** | Tên bạn, `Thảm Rừng`, 0 XP |
| **Cộng đồng → Dòng thời gian** | 5 bài đăng, bài `post-desk-setup` có 3 bình luận |
| **Cộng đồng → Nhóm học tập** | Nhóm `neu`, 4 thành viên, 6.160 XP; bấm 💬 mở chat có 8 tin |
| **Cộng đồng → Bảng xếp hạng** | 8 người, hàng của bạn tô xanh |
| Rời nhóm rồi **Tham gia nhóm** | Danh sách 3 nhóm kèm số thành viên |

## Mô hình dữ liệu — ai ghi vào đâu

| Nơi lưu | Là gì | Ai ghi |
|---|---|---|
| `topics/{id}/words` | **Giáo trình** — bộ từ để học | Admin |
| `users/{uid}/wordProgress` | Từ nào đã học, lịch ôn SRS | App khi user học |
| `users/{uid}/savedWords` | Từ user lưu từ **ảnh chụp** | App khi user bấm Lưu |
| `users/{uid}/dailyStats/{ngày}` | Nuôi streak và nhiệm vụ hằng ngày | App khi user trả lời |
| `users/{uid}.groupId` | **Thành viên nhóm** — không có subcollection riêng | App khi vào/rời nhóm |
| `groups/{id}/messages` | Tin nhắn chat nhóm | App khi user gửi |
| `posts/{id}/comments` | Bình luận bài đăng | App khi user bình luận |

Ba thứ dễ lẫn nhất là **giáo trình** (`topics/*/words`) ≠ **tiến độ học**
(`wordProgress`) ≠ **từ lưu từ ảnh** (`savedWords`). Chúng độc lập: lưu từ ảnh
chụp **không** làm tiến độ chủ đề tăng — camera chỉ để nhận biết vật thể và lưu
lại xem, không phải nguồn học.

`groups` và `shopItems` không có cột "ai ghi" vì client **chỉ đọc** — trừ
`groups/{id}` lúc tạo nhóm mới (phải đứng tên chính mình làm trưởng nhóm).
