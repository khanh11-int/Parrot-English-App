# Dữ liệu mẫu cần nhập vào Firestore

Hai collection `topics` và `shopItems` là **dữ liệu dùng chung, chỉ đọc** —
[firestore.rules](firestore.rules) chặn client ghi vào chúng, nên phải nhập qua
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

## 1b. Subcollection `topics/{id}/words` — giáo trình từ vựng

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

## Cách nhập trên Console

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

## Mô hình dữ liệu — ba thứ khác nhau, đừng lẫn

| Nơi lưu | Là gì | Ai ghi |
|---|---|---|
| `topics/{id}/words` | **Giáo trình** — bộ từ để học | Admin |
| `users/{uid}/wordProgress` | Từ nào đã học, lịch ôn SRS | App khi user học |
| `users/{uid}/savedWords` | Từ user lưu từ **ảnh chụp** | App khi user bấm Lưu |

Ba thứ này độc lập. Lưu từ ảnh chụp **không** làm tiến độ chủ đề tăng — camera
chỉ để nhận biết vật thể và lưu lại xem cho vui, không phải nguồn học.
