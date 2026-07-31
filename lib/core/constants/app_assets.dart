/// Đường dẫn tới toàn bộ ảnh trong `assets/images/`.
///
/// Luôn dùng hằng số ở đây thay vì viết chuỗi đường dẫn trực tiếp trong widget:
/// gõ sai đường dẫn chỉ lỗi lúc chạy, còn gõ sai tên hằng số thì lỗi lúc biên
/// dịch.
abstract final class AppAssets {
  static const _mascot = 'assets/images/mascot';
  static const _ring = 'assets/images/ring';
  static const _icons = 'assets/images/icons';
  static const _stickers = 'assets/images/stickers';
  static const _items = 'assets/images/items';

  // --- Mascot con vẹt ---------------------------------------------------
  static const mascotReading = '$_mascot/reading.png';
  static const mascotPhone = '$_mascot/phone.png';
  static const mascotTeacher = '$_mascot/teacher.png';
  static const mascotThumbsUp = '$_mascot/thumbs_up.png';
  static const mascotTrophy = '$_mascot/trophy.png';
  static const mascotQuest = '$_mascot/quest.png';
  static const mascotReward = '$_mascot/reward.png';
  static const mascotReminder = '$_mascot/reminder.png';
  static const mascotFavorite = '$_mascot/favorite.png';

  // --- Vòng tiến độ -----------------------------------------------------
  // Các ảnh này có số liệu nướng sẵn trong ảnh nên chỉ dùng làm ảnh tham
  // chiếu thiết kế; tiến độ thật vẽ bằng Flutter.
  static const ringLearnNew = '$_ring/learn_new.png';
  static const ringReview = '$_ring/review.png';
  static const ringTest = '$_ring/test.png';
  static const ringComplete = '$_ring/complete.png';

  // --- Icon hệ thống ----------------------------------------------------
  static const iconHome = '$_icons/home.png';
  static const iconStudy = '$_icons/study.png';
  static const iconQuest = '$_icons/quest.png';
  static const iconStats = '$_icons/stats.png';
  static const iconAchievement = '$_icons/achievement.png';
  static const iconNotification = '$_icons/notification.png';
  static const iconMessage = '$_icons/message.png';
  static const iconSettings = '$_icons/settings.png';
  static const iconProfile = '$_icons/profile.png';

  // --- Sticker cảm xúc --------------------------------------------------
  static const stickerHello = '$_stickers/hello.png';
  static const stickerLove = '$_stickers/love.png';
  static const stickerThinking = '$_stickers/thinking.png';
  static const stickerSurprised = '$_stickers/surprised.png';
  static const stickerHappy = '$_stickers/happy.png';
  static const stickerSad = '$_stickers/sad.png';
  static const stickerCheer = '$_stickers/cheer.png';
  static const stickerTired = '$_stickers/tired.png';
  static const stickerSorry = '$_stickers/sorry.png';
  static const stickerAwesome = '$_stickers/awesome.png';

  /// Toàn bộ sticker, dùng cho `StickerPicker`.
  static const allStickers = <String>[
    stickerHello,
    stickerLove,
    stickerThinking,
    stickerSurprised,
    stickerHappy,
    stickerSad,
    stickerCheer,
    stickerTired,
    stickerSorry,
    stickerAwesome,
  ];

  // --- Vật phẩm cửa hàng ------------------------------------------------
  // Hai ảnh này vẽ riêng cho hai vật phẩm, đặt tên theo đúng document id trên
  // Firestore (`boost-fruit`, `bark-shield`) để dễ đối chiếu.
  static const itemBoostFruit = '$_items/boost-fruit.png';
  static const itemBarkShield = '$_items/bark-shield.png';

  // --- Tiền tệ & icon phụ -----------------------------------------------
  static const itemDiamond = '$_items/diamond.png';
  static const itemCoin = '$_items/coin.png';
  static const itemHeart = '$_items/heart.png';
  static const itemEnergy = '$_items/energy.png';
  static const itemShield = '$_items/shield.png';
  static const itemGift = '$_items/gift.png';
  static const itemCalendar = '$_items/calendar.png';
  static const itemTarget = '$_items/target.png';
  static const itemLock = '$_items/lock.png';
}
