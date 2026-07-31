import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_rewards.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../../quiz/data/models/topic_document.dart';
import '../../domain/entities/topic_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../models/vocabulary_document.dart';

/// Giáo trình từ vựng và tiến độ học, lưu trên Firestore.
class FirebaseVocabularyRepository implements VocabularyRepository {
  const FirebaseVocabularyRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  String _requireUid() {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    return user.id;
  }

  CollectionReference<Map<String, dynamic>> _topicWords(String topicId) =>
      _firestore
          .collection(TopicDocument.collection)
          .doc(topicId)
          .collection(TopicWordDocument.collection);

  CollectionReference<Map<String, dynamic>> _progress(String uid) => _firestore
      .collection(UserDocument.collection)
      .doc(uid)
      .collection(WordProgressDocument.collection);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(UserDocument.collection).doc(uid);

  DocumentReference<Map<String, dynamic>> _topicProgress(
    String uid,
    String topicId,
  ) => _userDoc(uid).collection(TopicDocument.progressCollection).doc(topicId);

  DocumentReference<Map<String, dynamic>> _dailyStats(
    String uid,
    String date,
  ) => _userDoc(uid).collection(UserDocument.dailyStatsCollection).doc(date);

  @override
  Future<List<TopicWord>> getTopicWords(String topicId) async {
    try {
      final snapshot = await _topicWords(topicId).orderBy('order').get();
      return snapshot.docs
          .map((doc) => TopicWordDocument.toEntity(doc.id, topicId, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<List<WordProgress>> getProgress({String? topicId}) async {
    final uid = _requireUid();

    try {
      Query<Map<String, dynamic>> query = _progress(uid);
      if (topicId != null) {
        query = query.where('topicId', isEqualTo: topicId);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => WordProgressDocument.toEntity(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<List<WordProgress>> getDueProgress({int limit = 50}) async {
    final uid = _requireUid();

    try {
      final snapshot = await _progress(uid)
          .where('dueAt', isLessThanOrEqualTo: Timestamp.now())
          .orderBy('dueAt')
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => WordProgressDocument.toEntity(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> recordAnswer({
    required TopicWord word,
    required bool isCorrect,
  }) async {
    final uid = _requireUid();

    try {
      final doc = _progress(uid).doc(word.id);
      // Đọc song song: tiến độ của từ và hồ sơ (để tính streak).
      // Khoi tao truoc roi await tung cai: van chay song song vi future trong
      // Dart la eager. Khong dung `(f1, f2).wait` — no goi loi vao
      // ParallelWaitError nen `on FirebaseException` ben duoi se truot.
      final snapshotFuture = doc.get();
      final userSnapshotFuture = _userDoc(uid).get();
      final snapshot = await snapshotFuture;
      final userSnapshot = await userSnapshotFuture;
      final data = snapshot.data();

      final currentDays = switch (data?['reviewIntervalDays']) {
        final num value => value.toInt(),
        _ => 0,
      };
      final isFirstTime = !snapshot.exists;
      final nextDays = AppRewards.nextIntervalDays(
        currentDays: currentDays,
        isCorrect: isCorrect,
        isFirstTime: isFirstTime,
      );

      final batch = _firestore.batch();
      batch.set(
        doc,
        WordProgressDocument.toMap(
          word: word,
          reviewIntervalDays: nextDays,
          dueAt: DateTime.now().add(Duration(days: nextDays)),
        ),
        SetOptions(merge: true),
      );

      // Chỉ tăng số từ đã học của chủ đề ở **lần đầu** gặp từ này, nếu không ôn
      // lại một từ cũ cũng làm tiến độ chủ đề vượt quá tổng số từ.
      if (isFirstTime && word.topicId.isNotEmpty) {
        batch.set(_topicProgress(uid, word.topicId), {
          'learnedCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      _addRewards(
        batch: batch,
        uid: uid,
        isCorrect: isCorrect,
        isFirstTime: isFirstTime,
        userData: userSnapshot.data() ?? const <String, dynamic>{},
      );

      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  /// Cộng XP, hạt, streak và thống kê ngày vào cùng batch với tiến độ từ.
  ///
  /// Gộp vào một batch để không xảy ra chuyện ghi được tiến độ nhưng mất phần
  /// thưởng (hoặc ngược lại) khi mạng đứt giữa hai lời gọi.
  void _addRewards({
    required WriteBatch batch,
    required String uid,
    required bool isCorrect,
    required bool isFirstTime,
    required Map<String, dynamic> userData,
  }) {
    final now = DateTime.now();
    final today = UserDocument.dateKey(now);

    batch.set(_userDoc(uid), {
      // Trả lời sai vẫn tính là có hoạt động hôm nay, chỉ không được thưởng.
      if (isCorrect) ...{
        'experience': FieldValue.increment(
          AppRewards.experiencePerCorrectAnswer,
        ),
        'seeds': FieldValue.increment(AppRewards.seedsPerCorrectAnswer),
      },
      'lastActiveDate': today,
      'streakDays': UserDocument.nextStreak(userData, now: now),
    }, SetOptions(merge: true));

    batch.set(_dailyStats(uid, today), {
      if (isFirstTime) 'wordsLearned': FieldValue.increment(1),
      if (!isFirstTime) 'wordsReviewed': FieldValue.increment(1),
      'correctAnswers': FieldValue.increment(isCorrect ? 1 : 0),
      'answers': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền truy cập dữ liệu từ vựng.',
      ),
      'unavailable' => const NetworkFailure(),
      'failed-precondition' => const ServerFailure(
        'Firestore cần tạo index cho truy vấn này. '
        'Xem link trong log để tạo bằng một cú bấm.',
      ),
      _ => ServerFailure(error.message ?? 'Không truy cập được từ vựng.'),
    };
  }
}
