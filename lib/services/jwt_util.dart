import 'dart:convert';

/// Reads claims out of a JWT without verifying the signature - safe here because we only ever
/// read back the citizen's own id from a token the backend itself just issued to this device.
class JwtUtil {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String? citizenId(String token) => decodePayload(token)?['citizen_id'] as String?;
}
