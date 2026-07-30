# Đặc tả REST API — Parrot

Hợp đồng giữa app Flutter và **backend trung gian của chúng ta**. App đã cài đặt
xong phía client theo đúng tài liệu này (`lib/core/network/`, `data/models/`,
`data/repositories/*_remote_repository.dart`).

## Quy ước chung

| Hạng mục | Quy ước |
|---|---|
| Base URL | Truyền vào app lúc build: `--dart-define=PARROT_API_BASE_URL=...` |
| Định dạng | JSON, `Content-Type: application/json` |
| Tên field | `snake_case` |
| Xác thực | Header `Authorization: Bearer <token>` |
| Timeout app dùng | 15s cho request thường, 60s cho upload ảnh |

### ⚠️ Nguyên tắc bắt buộc

**API key của nhà cung cấp AI (Vision / LLM) chỉ nằm ở server.** App không bao
giờ gọi thẳng API của Google Vision / OpenAI / Anthropic. App mobile dịch ngược
được nên key nhúng trong app coi như đã công khai.

### Mã lỗi và cách app phản ứng

Body lỗi nên có dạng `{"message": "câu tiếng Việt cho người dùng"}` — app sẽ
hiển thị đúng câu đó.

| HTTP | App hiểu là | Có nút "Thử lại"? |
|---|---|---|
| 400, 422 | Dữ liệu gửi lên không hợp lệ | Không |
| 401, 403 | Hết phiên đăng nhập | Không |
| 404 | Không tìm thấy | Không |
| 429 | Gọi quá nhanh | Có |
| 5xx | Máy chủ gặp sự cố | Có |
| Timeout / mất mạng | Lỗi kết nối | Có |

---

## 1. Trang chủ

### `GET /me/home`

```json
{
  "user_name": "Công Tình",
  "streak_days": 1,
  "gem_count": 2,
  "seed_count": 15,
  "learn_goal":  { "title": "Học từ mới",  "completed": 9, "target": 15 },
  "review_goal": { "title": "Ôn tập ngay", "completed": 1, "target": 30 },
  "monthly_quest": {
    "title": "Nhiệm vụ tháng Chín",
    "quests": [
      { "title": "Học 300 từ trong tháng", "completed": 45, "target": 300 }
    ]
  },
  "daily_quests": {
    "title": "Nhiệm vụ hằng ngày",
    "quests": [
      { "title": "Lưu 5 từ mới qua hình ảnh", "completed": 3, "target": 5 },
      { "title": "Ôn tập 30 từ vựng", "completed": 0, "target": 30 },
      { "title": "Đăng hình ảnh lên cộng đồng 1 lần", "completed": 0, "target": 1 }
    ]
  }
}
```

`target` bằng `0` được app xử lý an toàn (tiến độ = 0), không crash.

---

## 2. Nhận diện ảnh → sinh từ vựng

Đây là tính năng cốt lõi và là endpoint **chậm nhất**, nên chia hai bước.

### `POST /scans` — gửi ảnh

`multipart/form-data`, field ảnh tên `image`.

Trả về **ngay lập tức**, không chờ AI xử lý xong:

```json
{ "id": "scan_01H...", "status": "processing" }
```

Nếu xử lý xong ngay thì trả luôn `status: "completed"` kèm `words` — app dùng
được luôn, khỏi hỏi lại.

### `GET /scans/{id}` — hỏi kết quả

App gọi lại mỗi **2 giây**, tối đa **30 lần** (tức chờ tối đa 1 phút) rồi báo
timeout cho người dùng.

```json
{
  "id": "scan_01H...",
  "status": "completed",
  "image_url": "https://cdn.parrot.example/scans/01H.jpg",
  "words": [
    {
      "id": "chair",
      "english": "chair",
      "vietnamese": "cái ghế",
      "phonetic": "/tʃeə(r)/",
      "confidence": 0.98,
      "bounding_box": { "left": 0.06, "top": 0.42, "width": 0.30, "height": 0.46 }
    }
  ]
}
```

**`bounding_box` phải theo tỉ lệ `0..1`** so với kích thước ảnh, không phải
pixel. App vẽ khung đè lên ảnh ở nhiều kích thước hiển thị khác nhau; nếu gửi
pixel thì khung sẽ lệch trên mọi máy có màn hình khác nhau.

`status` nhận `"queued"`, `"processing"`, `"completed"`, `"failed"`. Mọi giá trị
lạ được app coi là "chưa xong" và tiếp tục hỏi lại.

Khi `status: "failed"` thì kèm `error_message` để app hiện đúng nguyên nhân.

### `GET /topics` — danh sách chủ đề

```json
[
  { "id": "furniture", "name": "Đồ nội thất" },
  { "id": "office",    "name": "Văn phòng" }
]
```

App hiện đang chỉ dùng field `name`.

### `POST /vocabulary` — lưu từ đã chọn

```json
{
  "should_post": false,
  "words": [
    { "id": "chair", "english": "chair", "vietnamese": "cái ghế", "topic": "Đồ nội thất" }
  ]
}
```

`should_post: true` nghĩa là **lưu và đồng thời tạo bài đăng** lên Cộng đồng
(nút "Lưu và đăng tải"). `topic` có thể `null` khi người dùng chưa chọn chủ đề.

---

## 3. Phiên học & ôn tập

### `GET /me/topics` — chủ đề kèm tiến độ

Dùng cho trang chọn chủ đề (mục 5.4 `UI_SPEC.md`).

```json
[
  {
    "id": "health",
    "name": "Sức khoẻ",
    "learned_count": 4,
    "total_count": 18,
    "icon_url": "https://cdn.parrot.example/topics/health.png"
  }
]
```

App tự tính `%`, số từ còn lại và trạng thái "đã học xong" từ hai con số này —
**không cần gửi thêm field tiến độ**, nhờ vậy vòng tiến độ và nhãn không bao giờ
lệch nhau.

### `GET /sessions/learn` và `GET /sessions/review`

Cùng một schema. `/review` trả các từ **đã đến hạn ôn** theo SRS.

`/sessions/learn` nhận tham số truy vấn tuỳ chọn `?topic_id=health` để chỉ lấy
từ của một chủ đề. Không có tham số nghĩa là trộn mọi chủ đề.

```json
{
  "id": "sess_01H...",
  "title": "Học từ mới",
  "exercises": [
    {
      "type": "match_pairs",
      "pairs": [
        { "id": "fatigue", "english": "Fatigue", "vietnamese": "Sự mệt mỏi" },
        { "id": "cough",   "english": "Cough",   "vietnamese": "Ho" }
      ]
    },
    {
      "type": "multiple_choice",
      "word": { "id": "diet", "english": "Diet", "vietnamese": "Chế độ ăn uống" },
      "options": ["Chế độ ăn uống", "Ông", "Trầm cảm", "Con trai"],
      "correct_option": "Chế độ ăn uống"
    }
  ]
}
```

`type` hiện chỉ hỗ trợ `match_pairs` và `multiple_choice`. Gửi dạng khác app sẽ
báo lỗi rõ ràng thay vì bỏ qua vòng học — **thêm dạng bài mới cần cập nhật app
trước**.

`options` nên **đã xáo trộn sẵn** ở server. App không xáo lại.

### `POST /sessions/{id}/result`

```json
{ "learned_word_count": 3, "correct_count": 2, "wrong_count": 1 }
```

Server dùng dữ liệu này để cộng XP, cộng hạt và cập nhật lịch ôn SRS.

**App không chặn người học nếu endpoint này lỗi** — họ đã làm xong bài, chỉ ghi
log. Server nên chấp nhận gửi lại cùng một `session_id` mà không cộng XP hai lần
(idempotent).

### `GET /me/decks` — bộ từ cần ôn

```json
[
  { "topic": "Đồ nội thất", "total_count": 24, "mastered_count": 15, "due_count": 6 },
  { "topic": "Gia đình",    "total_count": 12, "mastered_count": 12, "due_count": 0 }
]
```

---

## 4. Cộng đồng

### `GET /feed`

```json
[
  {
    "id": "post_1",
    "author_name": "K64 - NEU",
    "author_avatar_url": "https://cdn.parrot.example/avatars/1.png",
    "time_ago": "5 tháng trước",
    "shared_word": {
      "english": "person",
      "vietnamese": "người",
      "phonetic": "/ˈpɜː.sən/"
    },
    "detected_label": "chair - cái ghế 1.00",
    "like_count": 4,
    "comment_count": 0,
    "bookmark_count": 0,
    "is_liked": false,
    "is_bookmarked": false
  }
]
```

**`time_ago` là chuỗi đã định dạng sẵn ở server**, không phải timestamp. Lý do:
đồng hồ máy người dùng có thể sai, và tránh việc mỗi client tự tính ra một cách
diễn đạt khác nhau.

### Thích / lưu bài

| Hành động | Request |
|---|---|
| Thích | `POST /posts/{id}/like` |
| Bỏ thích | `DELETE /posts/{id}/like` |
| Lưu bài | `POST /posts/{id}/bookmark` |
| Bỏ lưu | `DELETE /posts/{id}/bookmark` |

Cả bốn đều trả về **đối tượng bài đăng đầy đủ sau khi cập nhật** (cùng schema
như trong `/feed`). App cập nhật UI trước rồi mới gọi API; nếu API lỗi thì hoàn
tác, nên số đếm trả về phải chính xác.

### `GET /leaderboard`

```json
{
  "current_rank": "lower_canopy",
  "safe_zone_end_rank": 6,
  "entries": [
    { "rank": 1, "name": "Minh Anh", "avatar_url": "...", "experience": 312, "is_current_user": false },
    { "rank": 7, "name": "Công Tình", "avatar_url": "...", "experience": 98,  "is_current_user": true }
  ]
}
```

`current_rank` nhận một trong: `forest_floor`, `undergrowth`, `lower_canopy`,
`mid_canopy`, `upper_canopy`, `emergent` (6 tầng rừng, xem mục 2.6 `UI_SPEC.md`).

`safe_zone_end_rank` là hạng cuối cùng còn giữ được hạng — app vẽ dải
"TOP AN TOÀN" ngay dưới hạng này.

Đúng **một** entry có `is_current_user: true`; app ghim hàng đó ở đáy màn hình.

### `GET /me/group`

```json
{
  "group": {
    "name": "neu",
    "member_count": 8,
    "leader_name": "Hoang Duyen",
    "avatar_url": "...",
    "total_experience": 355,
    "days_remaining": 7
  }
}
```

Chưa tham gia nhóm nào thì trả `{"group": null}` với **HTTP 200** — đây là trạng
thái bình thường, không phải lỗi. App hiện màn hình mời tạo/tham gia nhóm.

Ngưỡng 3 mốc nhóm (Chồi Non 600 / Cây Vững 16000 / Đại Thụ 30000) hiện **cứng ở
client**. Nếu muốn server điều khiển thì cần thêm field và cập nhật app.

---

## 5. Cửa hàng

### `GET /shop`

```json
{
  "wallet": { "seeds": 150, "gems": 2 },
  "items": [
    {
      "id": "boost-fruit",
      "name": "Quả Tăng Tốc",
      "description": "Nhân đôi XP nhận được trong 15 phút",
      "icon_url": "https://cdn.parrot.example/items/boost.png",
      "price": 150,
      "currency": "seed",
      "owned_count": 1
    }
  ]
}
```

`currency` nhận `"seed"` (hạt — tiền mềm) hoặc `"gem"` (ngọc — tiền cứng). Giá
trị lạ được app coi là `seed`.

### `POST /shop/purchases`

```json
{ "item_id": "bark-shield" }
```

Trả về **toàn bộ object giống `GET /shop`** với ví và `owned_count` đã cập nhật.

App kiểm số dư ở client trước để không gửi request chắc chắn thất bại, nhưng
**server phải kiểm lại**: số dư có thể đã đổi ở thiết bị khác. Không đủ tiền thì
trả `422` kèm `message`.

---

## 6. Hồ sơ

### `GET /me/profile`

```json
{
  "name": "Công Tình",
  "avatar_url": "...",
  "post_count": 18,
  "follower_count": 1,
  "following_count": 5,
  "experience": 568,
  "streak_days": 1,
  "group_name": "neu",
  "recent_post_count": 9
}
```

**Không cần gửi `rank`**: app tự suy hạng từ `experience` theo thang 6 tầng, nên
hạng và thanh tiến độ không bao giờ lệch nhau.

`group_name` là `null` khi chưa vào nhóm.

---

## Chưa có trong hợp đồng này

Các phần app còn chưa dựng, nên chưa cần endpoint: đăng nhập/đăng ký, chat nhóm,
bình luận, tạo/tham gia nhóm, trang cá nhân người khác (`/users/{id}`), chi tiết
nhiệm vụ tháng.

Khi làm đăng nhập cần bàn thêm: cơ chế refresh token và nơi app lưu token
(`flutter_secure_storage`), vì hiện app đọc token từ `--dart-define` chỉ để tiện
phát triển.
