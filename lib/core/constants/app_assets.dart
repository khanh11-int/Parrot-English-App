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
  static const _ranks = 'assets/images/ranks';
  static const _topics = 'assets/images/topics';

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
  static const mascotFlying = '$_mascot/flying.png';
  static const mascotGraduate = '$_mascot/graduate.png';
  static const mascotMedal = '$_mascot/medal.png';
  static const mascotCelebration = '$_mascot/celebration.png';
  static const mascotComplete = '$_mascot/complete.png';
  static const mascotExplore = '$_mascot/explore.png';
  static const mascotPractice = '$_mascot/practice.png';
  static const mascotTest = '$_mascot/test.png';
  static const mascotTask = '$_mascot/task.png';
  static const mascotNote = '$_mascot/note.png';
  static const mascotChat = '$_mascot/chat.png';
  static const mascotMail = '$_mascot/mail.png';
  static const mascotCalendar = '$_mascot/calendar.png';
  static const mascotProfile = '$_mascot/profile.png';
  static const mascotSettings = '$_mascot/settings.png';
  static const mascotStatistics = '$_mascot/statistics.png';
  static const mascotRest = '$_mascot/rest.png';
  static const mascotNervous = '$_mascot/nervous.png';
  static const mascotExcited = '$_mascot/excited.png';
  static const mascotAngel = '$_mascot/angel.png';
  static const mascotDevil = '$_mascot/devil.png';

  // --- Vòng tiến độ -----------------------------------------------------
  // Ảnh có số liệu nướng sẵn nên chỉ dùng làm ảnh tham chiếu thiết kế; tiến độ
  // thật vẽ bằng Flutter. Bốn hằng số cũ (`learn_new`, `review`, `test`,
  // `complete`) trỏ vào file không tồn tại nên đã bỏ.
  static const ringProgress = '$_ring/progress.png';

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
  static const iconSignOut = '$_icons/sign-out.png';

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
  static const itemBook = '$_items/book.png';
  static const itemBell = '$_items/bell.png';
  static const itemTicket = '$_items/ticket.png';
  static const itemTrophy = '$_items/trophy.png';
  static const itemTarget = '$_items/target.png';
  static const itemLock = '$_items/lock.png';

  // --- Huy hiệu 6 hạng tầng rừng ----------------------------------------
  /// Huy hiệu của hạng theo [ForestRank.index] (0..5): vẹt nở từ trứng rồi lớn
  /// dần tới lúc đội vương miện.
  static String rankBadge(int rankIndex) =>
      '$_ranks/level-${rankIndex.clamp(0, 5) + 1}.png';

  /// Cả 6 huy hiệu, dùng khi cần hiện toàn thang hạng.
  static const allRankBadges = <String>[
    '$_ranks/level-1.png',
    '$_ranks/level-2.png',
    '$_ranks/level-3.png',
    '$_ranks/level-4.png',
    '$_ranks/level-5.png',
    '$_ranks/level-6.png',
  ];

  // --- Ảnh 13 chủ đề tiếng Anh ------------------------------------------
  // Bộ này rộng hơn 7 chủ đề đang có trên Firestore; phần chưa dùng để dành cho
  // lúc mở thêm chủ đề.
  static const topicAnimal = '$_topics/animal.png';
  static const topicClothes = '$_topics/clothes.png';
  static const topicDailyLife = '$_topics/daily-life.png';
  static const topicEmotions = '$_topics/emotions.png';
  static const topicFoodDrinks = '$_topics/food-drinks.png';
  static const topicHolidays = '$_topics/holidays.png';
  static const topicJobs = '$_topics/jobs.png';
  static const topicNatural = '$_topics/natural.png';
  static const topicPlaces = '$_topics/places.png';
  static const topicSchool = '$_topics/school.png';
  static const topicSports = '$_topics/sports.png';
  static const topicTechnology = '$_topics/technology.png';
  static const topicTransportation = '$_topics/transportation.png';
}
