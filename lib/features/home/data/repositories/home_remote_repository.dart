import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/home_dtos.dart';

/// Lấy dữ liệu trang chủ từ REST API.
class HomeRemoteRepository implements HomeRepository {
  const HomeRemoteRepository(this._client);

  final ApiClient _client;

  @override
  Future<HomeSummary> getSummary() async {
    final json = await _client.getObject(ApiEndpoints.home);
    return HomeSummaryDto.fromJson(json).toEntity();
  }
}
