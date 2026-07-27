import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient supabase;

  NotificationService(this.supabase);

  Future<void> sendKomentarNotification({
    required String token,
    required String title,
    required String body,
    required String route,
    required String routeGuru,
    required String? materiId,
    required String? tugasId,
    required String? ujianId,
    required String? kelasMapelId,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'quick-api-2',
        body: {
          'token': token,
          'title': title,
          'body': body,
          'routeSiswa': route,
          'routeGuru': routeGuru,
          'materiId': materiId ?? '',
          'tugasId': tugasId ?? '',
          'ujianId': ujianId ?? '',
          'kelasMapelId': kelasMapelId ?? '',
        },
      );

      // ignore: avoid_print
      print("Notif result: ${response.data}");
      print("route siswa : $route");
      print("routeGuru : $routeGuru");
    } catch (e) {
      // ignore: avoid_print
      print("Error sending notification: $e");
    }
  }
}
