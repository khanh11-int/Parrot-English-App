import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/features/vocabulary/data/models/vocabulary_document.dart';
import 'package:parrot/features/vocabulary/domain/entities/topic_word.dart';

void main() {
  const word = TopicWord(
    id: 'chair',
    topicId: 'furniture',
    english: 'chair',
    vietnamese: 'cái ghế',
    phonetic: '/tʃeə(r)/',
  );
  final dueAt = DateTime(2026, 8, 1);

  group('WordProgressDocument.toCreateMap', () {
    test('ghi đủ nội dung từ ở lần đầu', () {
      final map = WordProgressDocument.toCreateMap(
        word: word,
        reviewIntervalDays: 0,
        dueAt: dueAt,
      );

      expect(map['topicId'], 'furniture');
      expect(map['english'], 'chair');
      expect(map['vietnamese'], 'cái ghế');
      expect(map['phonetic'], '/tʃeə(r)/');
      expect(map['reviewIntervalDays'], 0);
    });
  });

  group('WordProgressDocument.toUpdateMap', () {
    test('chỉ ghi lịch ôn, không nhắc tới nội dung từ', () {
      // Đây là điểm mấu chốt. `SetOptions(merge: true)` giữ nguyên field không
      // có trong map, nhưng ghi đè field nào có mặt. Phiên ôn tập trộn nhiều
      // chủ đề nên truyền nội dung rỗng — nếu map này có khoá `english` thì chữ
      // đúng đang lưu bị ghi thành chuỗi rỗng.
      final map = WordProgressDocument.toUpdateMap(
        word: word,
        storedTopicId: 'furniture',
        reviewIntervalDays: 3,
        dueAt: dueAt,
      );

      expect(map.keys, unorderedEquals(['reviewIntervalDays', 'dueAt']));
      expect(map.containsKey('english'), isFalse);
      expect(map.containsKey('vietnamese'), isFalse);
      expect(map.containsKey('phonetic'), isFalse);
      expect(map['reviewIntervalDays'], 3);
    });

    test('không ghi topicId khi Firestore đã có, dù người gọi truyền rỗng', () {
      // Phiên ôn tập trộn chủ đề truyền `topicId` rỗng. Ghi lại là xoá mất liên
      // kết chủ đề → `getDecks` bỏ qua tiến độ đó → bộ từ tụt về "Đã học 0/8".
      final map = WordProgressDocument.toUpdateMap(
        word: const TopicWord(
          id: 'chair',
          topicId: '',
          english: '',
          vietnamese: '',
          phonetic: '',
        ),
        storedTopicId: 'furniture',
        reviewIntervalDays: 1,
        dueAt: dueAt,
      );

      expect(map.containsKey('topicId'), isFalse);
    });

    test('vá lại topicId khi dữ liệu cũ đã bị xoá mất', () {
      // Tiến độ bị bản cũ ghi rỗng: học lại từ đó trong chủ đề của nó là tự
      // khôi phục, không cần script sửa dữ liệu.
      final map = WordProgressDocument.toUpdateMap(
        word: word,
        storedTopicId: '',
        reviewIntervalDays: 0,
        dueAt: dueAt,
      );

      expect(map['topicId'], 'furniture');
    });

    test('không vá bằng chuỗi rỗng khi cả hai bên đều rỗng', () {
      final map = WordProgressDocument.toUpdateMap(
        word: const TopicWord(
          id: 'chair',
          topicId: '',
          english: 'chair',
          vietnamese: 'cái ghế',
          phonetic: '',
        ),
        storedTopicId: '',
        reviewIntervalDays: 0,
        dueAt: dueAt,
      );

      expect(map.containsKey('topicId'), isFalse);
    });
  });

  group('WordProgressDocument.toEntity', () {
    test('đọc được tiến độ đã ghi', () {
      final entity = WordProgressDocument.toEntity(
        'chair',
        WordProgressDocument.toCreateMap(
          word: word,
          reviewIntervalDays: 21,
          dueAt: dueAt,
        ),
      );

      expect(entity.wordId, 'chair');
      expect(entity.topicId, 'furniture');
      expect(entity.dueAt, dueAt);
      // 21 ngày là mốc "đã thuộc".
      expect(entity.isMastered, isTrue);
    });

    test('thiếu field hoặc sai kiểu thì trả mặc định, không làm sập', () {
      final entity = WordProgressDocument.toEntity('chair', const {
        'topicId': 123,
        'reviewIntervalDays': 'nhiều',
      });

      expect(entity.topicId, '');
      expect(entity.reviewIntervalDays, 0);
      // `dueAt` rỗng nghĩa là đến hạn ngay.
      expect(entity.dueAt, isNull);
      expect(entity.isDue(DateTime(2026, 8, 1)), isTrue);
    });
  });
}
