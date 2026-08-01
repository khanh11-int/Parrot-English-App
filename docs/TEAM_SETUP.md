# Chia sẻ Firebase cho cả nhóm

Nhóm 5 người dùng **một** Firebase project: `parrot-english-app`. Tài liệu này
nói ai cần quyền gì và **không** cần quyền gì.

## Điều quan trọng nhất: chạy app KHÔNG cần quyền Firebase

Hai file cấu hình đã nằm trong repo:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

Ai clone repo về cũng `flutter run` được ngay, thấy đúng 7 chủ đề / 56 từ của
nhóm, đăng ký được tài khoản trong app. **Không cần được mời vào Firebase
Console, không cần `firebase login`, không cần chạy `flutterfire configure`.**

Lý do: `apiKey` trong hai file đó không phải mật khẩu. Nó là mã định danh
project, ai dịch ngược app cũng lấy được — Google ghi rõ trong tài liệu là được
phép công khai. Cái quyết định làm được gì là **Firebase Auth + Firestore
rules**, không phải key.

> Vậy nên: bạn **không phải gửi file gì cho ai** để họ chạy được app. Chỉ cần họ
> `git clone`.

## Hai hệ thống quyền khác nhau, đừng lẫn

| | Quản cái gì | Cấp bằng |
|---|---|---|
| **IAM** (Console → *Users and permissions*) | Xem/sửa dữ liệu trên **Console**, chạy `firebase deploy` | Chủ project mời từng email |
| **Firestore rules** | App đọc/ghi được gì **khi đang chạy** | [`firestore.rules`](../firestore.rules), theo `request.auth.uid` |

Một bạn không có quyền IAM nào vẫn dùng app đầy đủ: học từ, tạo nhóm, chat.
Ngược lại, một bạn có quyền Owner vẫn không đọc được `wordProgress` của người
khác **qua app**, vì rules chặn.

## Mời người vào Console

Chủ project mở:
https://console.firebase.google.com/project/parrot-english-app/settings/iam
→ **Add member** → nhập email Google của từng bạn → chọn role.

Chia theo việc thật, không cho ai cũng quyền cao nhất:

| Ai | Role | Làm được | Không làm được |
|---|---|---|---|
| Bạn (chủ project) | **Owner** | mọi thứ | — |
| 1–2 bạn lo dữ liệu & rules | **Firebase Develop Admin** | sửa Firestore, deploy rules/indexes, xem Auth users | đổi thanh toán, mời/xoá người khác |
| Các bạn còn lại | **Firebase Develop Viewer** | xem Firestore & Auth users để gỡ lỗi | ghi dữ liệu, deploy |

> [!WARNING]
> **Chỉ một người giữ Owner.** Owner xoá được cả project và mời/xoá thành viên
> khác. Cũng đừng cho `Editor` toàn cục nếu chỉ cần sửa Firestore — `Editor`
> rộng hơn `Firebase Develop Admin` khá nhiều.

Người được mời phải bấm link trong email mời, hoặc vào Console thấy project
xuất hiện sẵn.

## Dữ liệu nào dùng chung, dữ liệu nào riêng từng người

Cả 5 người trỏ vào **một** Firestore, nhưng không phải mọi thứ đều chung:

| Đường dẫn | Chung hay riêng | Ghi chú |
|---|---|---|
| `topics/*`, `topics/*/words/*` | **chung, chỉ đọc** | 7 chủ đề + 56 từ. Nạp **một lần**, cả nhóm dùng. Rules chặn app ghi vào đây |
| `shopItems/*` | **chung, chỉ đọc** | 2 vật phẩm |
| `users/{uid}` | riêng từng người | XP, hạt, streak. Ai đăng nhập cũng **đọc** được của người khác — đó là cách bảng xếp hạng chạy |
| `users/{uid}/wordProgress/*` | riêng, kín | Chỉ chủ sở hữu đọc được |
| `groups/{id}` + `messages` | chung cho người đăng nhập | Nhóm học tập là công khai |

Mỗi bạn **tự đăng ký một tài khoản** trong app (email + mật khẩu). Tiến độ học
của mỗi người tách biệt, nên 5 người test song song không đạp lên nhau.

Điểm lợi tình cờ: 5 tài khoản thật làm bảng xếp hạng và nhóm học tập test được
đúng thực tế, thay vì chỉ có một hàng.

## Nạp dữ liệu mẫu — một người làm, một lần

7 chủ đề / 56 từ / 2 vật phẩm nạp theo [SEED_DATA.md](SEED_DATA.md). Vì cả nhóm
dùng chung Firestore nên **chỉ một người làm việc này**, những người khác clone
về là đã thấy. Người làm cần role `Firebase Develop Admin` trở lên.

## Deploy rules và indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Không cần `--project` vì [`.firebaserc`](../.firebaserc) đã ghim
`parrot-english-app`.

> [!CAUTION]
> Rules là **toàn project, không có bản riêng từng máy**. Ai deploy là đổi cho
> cả 5 người ngay lập tức — deploy một bản rules sai thì app của cả nhóm hỏng.
> Nên: sửa `firestore.rules` thì mở pull request, đừng deploy thẳng.

## Hạn mức gói Spark dùng chung

Gói miễn phí tính theo **project**, không theo người. Hạn mức Firestore mỗi
ngày: khoảng **50.000 lượt đọc / 20.000 lượt ghi / 1 GiB lưu trữ**. 5 người hot
reload liên tục thì tiêu nhanh hơn tưởng, mà hết hạn mức là app của **cả nhóm**
báo lỗi tới nửa đêm giờ Mỹ (giờ reset).

Xem mức đã dùng:
https://console.firebase.google.com/project/parrot-english-app/usage

Con số hạn mức Google có đổi theo thời gian — tin trang *Usage* của Console hơn
tin tài liệu này.

## Việc KHÔNG được làm

- **Đừng chạy `flutterfire configure`** — nó ghi đè `firebase_options.dart` và
  `google-services.json` bằng project riêng của bạn. Máy bạn sẽ trỏ sang một
  Firestore trống (không có chủ đề nào), và commit lên thì kéo cả nhóm theo.
- **Đừng commit service account JSON.** File đó *là* bí mật thật — ai có nó là
  toàn quyền project, bỏ qua sạch mọi rules. `.gitignore` đã chặn
  `*serviceAccount*.json` và `*-firebase-adminsdk-*.json`; đừng đổi tên để lách.
- **Đừng xoá collection trên Console cho "sạch"** khi đang gỡ lỗi. Đó là dữ liệu
  của 4 người khác.
