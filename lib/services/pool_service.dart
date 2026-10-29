import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'jwt_util.dart';

/// Bumped whenever an access event (e.g. a kiosk QR redeem) may have changed the
/// citizen's rights/history server-side, so screens kept alive by IndexedStack know to refetch.
final ValueNotifier<int> accessRefreshTick = ValueNotifier<int>(0);

/// Which family member's profile is currently being viewed/acted on. Null means "self" (the
/// logged-in citizen). Set from the profile switcher in HomeShell; screens listen to this the
/// same way they listen to [accessRefreshTick] so switching profiles reloads their data.
final ValueNotifier<String?> activeCitizenId = ValueNotifier<String?>(null);

class PoolService {
  final ApiClient _client = ApiClient();

  Future<String?> get currentCitizenId async {
    final token = await _client.currentToken;
    return token != null ? JwtUtil.citizenId(token) : null;
  }

  /// The profile currently acting - the selected family member, or self if none selected.
  Future<String?> get effectiveCitizenId async => activeCitizenId.value ?? await currentCitizenId;

  Future<ApiEnvelope<Map<String, dynamic>>> requestLoginCode(String nationalId, String phone) async {
    final result = await _client.post(
      '/api/mobile/auth/request-code',
      {'nationalId': nationalId, 'phone': phone},
      (json) => json as Map<String, dynamic>,
    );
    return result;
  }

  Future<String?> verifyLoginCode(String requestId, String code) async {
    final result = await _client.post('/api/mobile/auth/verify-code', {'requestId': requestId, 'code': code}, (json) => json as Map<String, dynamic>);
    if (!result.success) return result.message ?? 'Giriş başarısız.';
    final token = result.data!['accessToken'] as String;
    await _client.saveToken(token);
    return null;
  }

  Future<void> logout() => _client.clearToken();

  Future<bool> get isLoggedIn => _client.isLoggedIn;

  Future<HomeSummary?> fetchHome() async {
    final citizenId = await effectiveCitizenId;
    final path = citizenId == null ? '/api/mobile/me' : '/api/mobile/me?citizenId=$citizenId';
    final result = await _client.get(path, (json) => HomeSummary.fromJson(json));
    return result.success ? result.data : null;
  }

  Future<List<FamilyMember>> fetchFamily() async {
    final result = await _client.get(
      '/api/mobile/family',
      (json) => (json as List).map((e) => FamilyMember.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<String?> issueQrToken() async {
    final citizenId = activeCitizenId.value;
    final result = await _client.post(
      '/api/mobile/access/qr-token',
      {if (citizenId != null) 'citizenId': citizenId},
      (json) => json as Map<String, dynamic>,
    );
    return result.success ? result.data!['token'] as String : null;
  }

  Future<Map<String, dynamic>> redeemKioskQr(String raw) async {
    if (!raw.startsWith('STEYS-KIOSK:')) return {'approved': false, 'message': 'Bu QR kodu STEYS giriş kodu değil.'};
    final id = raw.substring('STEYS-KIOSK:'.length);
    final body = {'challengeId': id, if (activeCitizenId.value != null) 'citizenId': activeCitizenId.value};
    final result = await _client.post('/api/mobile/access/kiosk-qr/redeem', body, (json) => json as Map<String, dynamic>);
    accessRefreshTick.value++;
    return result.success ? result.data! : {'approved': false, 'message': result.message ?? 'Giriş yapılamadı.'};
  }

  Future<List<SessionOccurrence>> fetchSessions() async {
    final result = await _client.get(
      '/api/session-occurrences',
      (json) => (json as List).map((e) => SessionOccurrence.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<String?> bookReservation(String sessionOccurrenceId) async {
    final citizenId = activeCitizenId.value;
    final result = await _client.post(
      '/api/reservations',
      {'sessionOccurrenceId': sessionOccurrenceId, if (citizenId != null) 'citizenId': citizenId},
      (json) => json,
    );
    return result.success ? null : (result.message ?? 'Rezervasyon yapılamadı.');
  }

  Future<List<ReservationItem>> fetchMyReservations(String citizenId) async {
    final result = await _client.get(
      '/api/reservations/by-citizen/$citizenId',
      (json) => (json as List).map((e) => ReservationItem.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<List<AccessHistoryItem>> fetchAccessHistory() async {
    final citizenId = await effectiveCitizenId;
    final path = citizenId == null ? '/api/mobile/access-history' : '/api/mobile/access-history?citizenId=$citizenId';
    final result = await _client.get(
      path,
      (json) => (json as List).map((e) => AccessHistoryItem.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<List<MembershipItem>> fetchMyMemberships(String citizenId) async {
    final result = await _client.get(
      '/api/memberships/by-citizen/$citizenId',
      (json) => (json as List).map((e) => MembershipItem.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<String?> exportMyData() async {
    final result = await _client.get('/api/mobile/me/export', (json) => json);
    if (!result.success) return null;
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(result.data);
  }

  Future<String?> requestAccountDeletion() async {
    final result = await _client.post('/api/mobile/me/delete-request', {}, (json) => json);
    return result.success ? (result.message ?? 'Talebiniz alındı.') : null;
  }

  Future<List<AnnouncementItem>> fetchAnnouncements() async {
    final result = await _client.get(
      '/api/mobile/announcements',
      (json) => (json as List).map((e) => AnnouncementItem.fromJson(e)).toList(),
    );
    return result.success ? result.data! : [];
  }

  Future<List<CourseItem>> fetchCourses() async {
    final citizenId = await effectiveCitizenId;
    final path = citizenId == null ? '/api/mobile/courses' : '/api/mobile/courses?citizenId=$citizenId';
    final result = await _client.get(path, (json) => (json as List).map((e) => CourseItem.fromJson(e)).toList());
    return result.success ? result.data! : [];
  }
}
