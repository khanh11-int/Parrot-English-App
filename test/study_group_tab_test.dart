import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';
import 'package:parrot/features/community/data/repositories/community_mock_repository.dart';
import 'package:parrot/features/community/domain/entities/study_group.dart';
import 'package:parrot/features/community/presentation/providers/community_providers.dart';
import 'package:parrot/shared/widgets/async_value_view.dart';

import 'helpers/test_app.dart';

/// Như bản mock nhưng người dùng **chưa ở nhóm nào** — trạng thái sau khi rời
/// nhóm.
class _NoGroupRepository extends CommunityMockRepository {
  const _NoGroupRepository();

  @override
  Future<StudyGroup?> getStudyGroup() async => null;
}

Future<void> _openGroupTab(WidgetTester tester) async {
  final router = await pumpParrotApp(
    tester,
    extraOverrides: [
      communityRepositoryProvider.overrideWithValue(const _NoGroupRepository()),
    ],
  );
  router.go(AppRoutes.community);
  await settleMockData(tester);

  await tester.tap(find.text('Nhóm học tập'));

  // Tab này chờ hai lần gọi nối tiếp (nhóm hiện tại → danh sách nhóm có thể
  // tham gia) nên cần nhiều nhịp hơn `settleMockData`.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

void main() {
  testWidgets('chưa ở nhóm nào thì hiện lời mời và nút tạo nhóm', (
    tester,
  ) async {
    await _openGroupTab(tester);

    expect(find.text('Bạn chưa ở nhóm nào'), findsOneWidget);
    expect(find.text('Tạo nhóm mới'), findsOneWidget);
  });

  testWidgets(
    'chưa ở nhóm nào thì liệt kê nhóm có thể tham gia ngay trên tab',
    (tester) async {
      // Trước đây danh sách này nằm trong bottom sheet phải bấm mới thấy, nên
      // người vừa rời nhóm mở tab lên không biết có nhóm nào để vào.
      await _openGroupTab(tester);

      expect(find.text('Nhóm có thể tham gia'), findsOneWidget);
      expect(
        find.text('8 thành viên · Trưởng nhóm Hoang Duyen'),
        findsOneWidget,
      );
      expect(find.text('K64 - NEU'), findsOneWidget);
      // Mỗi nhóm một nút, không phải cả thẻ bấm được.
      expect(find.text('Tham gia'), findsNWidgets(2));
    },
  );

  group('AsyncValueView với dữ liệu nullable', () {
    testWidgets('giá trị null vẫn vẽ nội dung, không quay vòng tải mãi', (
      tester,
    ) async {
      // Đây là lỗi làm tab Nhóm trắng trơn sau khi rời nhóm: `studyGroupProvider`
      // là `FutureProvider<StudyGroup?>` nên `null` là dữ liệu hợp lệ ("chưa vào
      // nhóm nào"), nhưng khớp mẫu theo `valueOrNull?` lại trượt xuống nhánh
      // đang-tải.
      await tester.pumpWidget(
        const MaterialApp(
          home: AsyncValueView<String?>(
            value: AsyncData<String?>(null),
            data: _nullSafeLabel,
          ),
        ),
      );

      expect(find.text('chưa có gì'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('vẫn hiện đang tải khi thật sự chưa có dữ liệu', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AsyncValueView<String?>(
            value: AsyncLoading<String?>(),
            // Skeleton mặc định có animation nhấp nháy chạy vô hạn, để nguyên
            // thì test kết thúc với timer còn treo.
            loading: Text('đang tải'),
            data: _nullSafeLabel,
          ),
        ),
      );

      expect(find.text('đang tải'), findsOneWidget);

      expect(find.text('chưa có gì'), findsNothing);
    });
  });
}

Widget _nullSafeLabel(String? value) => Text(value ?? 'chưa có gì');
