// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/daftar_pengerjaan_ujian.dart';
import '../../models/guru/jawaban_ujian_model.dart';
import '../../models/guru/soal_ujian_model.dart';
import '../../models/guru/soal_ujian_siswa.dart';
import '../../models/guru/ujian_model.dart';
import 'notification_service.dart';

class UjianService {
  final SupabaseClient supabase;

  UjianService(this.supabase);

  Future<UjianResponse> getUjianKelas({
    required int semesterId,
    required String tipeUjian,
    int page = 1,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_ujian',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_search': search,
          'p_semester_id': semesterId,
          'p_tipe_ujian': tipeUjian,
        },
      );

      // print("Data tugas kelas dari Supabase: $response");

      if (response == null) {
        return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      if (response is String) {
        return UjianResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return UjianResponse.fromJson(response);
      }

      return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getUjianKelas: $e");
      return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<bool> addUjianSTSorSAS({
    required String tipeUjian,
    required String deskripsi,
    required String tanggalUjian,
    required String jamMulai,
    required String jamSelesai,
    required String statusNilai,
    required String statusKonten,
    required List<SoalUjian> soalUjian,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');

    try {
      final response =
          await supabase.rpc(
                'add_sts_or_sas_new',
                params: {
                  'p_kelas_mapel_id': kelasMapelId,
                  'p_tipe_ujian': tipeUjian,
                  'p_deskripsi': deskripsi,
                  'p_tanggal_ujian': tanggalUjian,
                  'p_jam_mulai': jamMulai,
                  'p_jam_selesai': jamSelesai,
                  'p_status_nilai': statusNilai,
                  'p_status_konten': statusKonten,
                  'p_soal_ujian': soalUjian,
                },
              )
              as Map<String, dynamic>;

      final int ujianId = response['ujian_id'];
      final String judulDefault = response['judul_default'];

      // 2. Ambil daftar penerima notif
      final penerimaResponse = await supabase.rpc(
        'get_all_siswa_kelas_mapel',
        params: {'p_kelas_mapel_id': kelasMapelId},
      );

      List<dynamic> penerimaList = [];

      // Handle response berdasarkan tipe
      if (penerimaResponse is String) {
        // Jika response adalah string JSON
        try {
          final parsed = jsonDecode(penerimaResponse) as Map<String, dynamic>;
          print("📱 Parsed keys: ${parsed.keys}");

          if (parsed.containsKey('data')) {
            final data = parsed['data'];
            if (data is List) {
              penerimaList = data;
              print("📱 Data is List with ${penerimaList.length} items");
            } else if (data is String) {
              // Jika data masih string JSON
              final dataParsed = jsonDecode(data) as List<dynamic>;
              penerimaList = dataParsed;
            }
          }
        } catch (e) {
          print("⚠️ Gagal parse response string: $e");
        }
      } else if (penerimaResponse is Map<String, dynamic>) {
        // Jika response sudah Map
        print("📱 Map keys: ${penerimaResponse.keys}");

        if (penerimaResponse.containsKey('data')) {
          final data = penerimaResponse['data'];
          if (data is List) {
            penerimaList = data;
          } else if (data is String) {
            try {
              final dataParsed = jsonDecode(data) as List<dynamic>;
              penerimaList = dataParsed;
            } catch (e) {
              print("⚠️ Gagal parse data string: $e");
            }
          }
        }
      }

      print("📱 Jumlah penerima notifikasi: ${penerimaList.length}");

      for (var row in penerimaList) {
        try {
          Map<String, dynamic> rowMap;

          // Convert row ke Map
          if (row is Map<String, dynamic>) {
            rowMap = row;
          } else if (row is Map) {
            rowMap = Map<String, dynamic>.from(row);
          } else {
            print("⚠️ Format row tidak valid: $row");
            continue;
          }

          // Debug row data
          print("📱 Row data: ${rowMap.keys}");

          final token = rowMap['token']?.toString();
          final nama = rowMap['nama']?.toString() ?? 'Unknown';
          final userId = rowMap['user_id']?.toString() ?? 'N/A';

          print("📱 Memproses siswa: $nama (user_id: $userId)");

          if (token != null && token.isNotEmpty) {
            await NotificationService(supabase).sendKomentarNotification(
              token: token,
              title: 'Ujian Baru',
              body: "'$judulDefault'",
              route: '/dashboard/siswa/kelas/$kelasMapelId/detail-ujian',
              routeGuru: '/dashboard/guru/kelas/$kelasMapelId/detail-ujian',
              materiId: '',
              tugasId: '',
              ujianId: ujianId.toString(),
              kelasMapelId: kelasMapelId.toString(),
            );

            print("✅ Notifikasi dikirim ke $nama");
          }
        } catch (e) {
          print("❌ Gagal proses penerima: $e");
          print("❌ Stack trace: $e");
        }
      }

      print("✅ Response addUjianSTSorSAS : $response");
      return true;
    } catch (e) {
      print("❌ Error addUjianSTSorSAS: $e");
      return false;
    }
  }

  Future<bool> addUjianSumatifLM({
    required int tujuanPemebelajaranId,
    required String tipeUjian,
    required String deskripsi,
    required String tanggalUjian,
    required String jamMulai,
    required String jamSelesai,
    required String statusNilai,
    required String statusKonten,
    required List<SoalUjian> soalUjian,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');

    try {
      final response =
          await supabase.rpc(
                'add_sumatif_lingkup_materi_new',
                params: {
                  'p_tujuan_pembelajaran_id': tujuanPemebelajaranId,
                  'p_kelas_mapel_id': kelasMapelId,
                  'p_tipe_ujian': tipeUjian,
                  'p_deskripsi': deskripsi,
                  'p_tanggal_ujian': tanggalUjian,
                  'p_jam_mulai': jamMulai,
                  'p_jam_selesai': jamSelesai,
                  'p_status_nilai': statusNilai,
                  'p_status_konten': statusKonten,
                  'p_soal_ujian': soalUjian,
                },
              )
              as Map<String, dynamic>;

      final int ujianId = response['ujian_id'];
      final String judulDefault = response['judul_default'];

      print("✅ Response addUjianSumatifLM : $response");

      // 2. Ambil daftar penerima notif
      final penerimaResponse = await supabase.rpc(
        'get_all_siswa_kelas_mapel',
        params: {'p_kelas_mapel_id': kelasMapelId},
      );

      List<dynamic> penerimaList = [];

      // Handle response berdasarkan tipe
      if (penerimaResponse is String) {
        // Jika response adalah string JSON
        try {
          final parsed = jsonDecode(penerimaResponse) as Map<String, dynamic>;
          print("📱 Parsed keys: ${parsed.keys}");

          if (parsed.containsKey('data')) {
            final data = parsed['data'];
            if (data is List) {
              penerimaList = data;
              print("📱 Data is List with ${penerimaList.length} items");
            } else if (data is String) {
              // Jika data masih string JSON
              final dataParsed = jsonDecode(data) as List<dynamic>;
              penerimaList = dataParsed;
            }
          }
        } catch (e) {
          print("⚠️ Gagal parse response string: $e");
        }
      } else if (penerimaResponse is Map<String, dynamic>) {
        // Jika response sudah Map
        print("📱 Map keys: ${penerimaResponse.keys}");

        if (penerimaResponse.containsKey('data')) {
          final data = penerimaResponse['data'];
          if (data is List) {
            penerimaList = data;
          } else if (data is String) {
            try {
              final dataParsed = jsonDecode(data) as List<dynamic>;
              penerimaList = dataParsed;
            } catch (e) {
              print("⚠️ Gagal parse data string: $e");
            }
          }
        }
      }

      print("📱 Jumlah penerima notifikasi: ${penerimaList.length}");

      for (var row in penerimaList) {
        try {
          Map<String, dynamic> rowMap;

          // Convert row ke Map
          if (row is Map<String, dynamic>) {
            rowMap = row;
          } else if (row is Map) {
            rowMap = Map<String, dynamic>.from(row);
          } else {
            print("⚠️ Format row tidak valid: $row");
            continue;
          }

          // Debug row data
          print("📱 Row data: ${rowMap.keys}");

          final token = rowMap['token']?.toString();
          final nama = rowMap['nama']?.toString() ?? 'Unknown';
          final userId = rowMap['user_id']?.toString() ?? 'N/A';

          print("📱 Memproses siswa: $nama (user_id: $userId)");

          if (token != null && token.isNotEmpty) {
            await NotificationService(supabase).sendKomentarNotification(
              token: token,
              title: 'Ujian Baru',
              body: "'$judulDefault'",
              route: '/dashboard/siswa/kelas/$kelasMapelId/detail-ujian',
              routeGuru: '/dashboard/guru/kelas/$kelasMapelId/detail-ujian',
              materiId: '',
              tugasId: '',
              ujianId: ujianId.toString(),
              kelasMapelId: kelasMapelId.toString(),
            );

            print("✅ Notifikasi dikirim ke $nama");
          }
        } catch (e) {
          print("❌ Gagal proses penerima: $e");
          print("❌ Stack trace: $e");
        }
      }

      return true;
    } catch (e) {
      print("❌ Error addUjianSumatifLM: $e");
      return false;
    }
  }

  Future<bool> updateNilaiJawaban({
    required int jawabanUjianId,
    required double nilaiJawaban,
  }) async {
    // final prefs = await SharedPreferences.getInstance();
    // final kelasMapelId = prefs.getInt('kelasMapelId');

    try {
      final response = await supabase.rpc(
        'update_nilai_esai_new',
        params: {
          'p_jawaban_ujian_id': jawabanUjianId,
          'p_nilai_jawaban': nilaiJawaban,
        },
      );

      print("✅ Response updateNilaiJawaban : $response");
      return true;
    } catch (e) {
      print("❌ Error updateNilaiJawaban: $e");
      return false;
    }
  }

  // Update fungsi updateKelompokBelajar untuk menyesuaikan dengan RPC
  // Future<bool> updateKelompokBelajar({
  //   required int kelompokId,
  //   required List<int> siswaId,
  // }) async {
  //   try {
  //     final response = await supabase.rpc(
  //       'update_kelompok_belajar',
  //       params: {'p_kelompok_belajar_id': kelompokId, 'p_siswa_id': siswaId},
  //     );

  //     print("Response updateKelompokBelajar: $response");
  //     return true;
  //   } catch (e) {
  //     print("Error updateKelompokBelajar: $e");
  //     return false;
  //   }
  // }

  Future<void> deleteUjianKelas({required int ujianId}) async {
    try {
      final response = await supabase.rpc(
        'delete_ujian_kelas',
        params: {'p_ujian_id': ujianId},
      );

      if (response == null) {
        throw Exception('Failed to delete ujian');
      }

      print("Response deleteUjianKelas: $response");
    } catch (e) {
      print("Error deleteUjianKelas: $e");
      rethrow;
    }
  }

  Future<DaftarPengerjaanUjianResponse> getDaftarPengerjaanUjian({
    int page = 1,
    String? search,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');
      final ujianId = prefs.getInt('ujianId');

      final response = await supabase.rpc(
        'get_daftar_pengerjaan_ujian_2',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_ujian_id': ujianId,
          'p_page': page,
          'p_search': search,
          'p_limit': limit,
        },
      );

      print("Data jawaban ujian dari Supabase: $response");

      if (response == null) {
        return DaftarPengerjaanUjianResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return DaftarPengerjaanUjianResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return DaftarPengerjaanUjianResponse.fromJson(response);
      }

      return DaftarPengerjaanUjianResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getDaftarPengerjaanUjian: $e");
      return DaftarPengerjaanUjianResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }

  Future<List<SoalUjianSiswa>> getSoalUjianSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ujianId = prefs.getInt('ujianId');

      final response = await supabase.rpc(
        'get_soal_ujian',
        params: {'p_ujian_id': ujianId},
      );

      print("Data getSoalUjianSiswa dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => SoalUjianSiswa.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getSoalUjianSiswa: $e");
      return [];
    }
  }

  // Di ujian_service.dart - tambahkan fungsi ini
  Future<List<JawabanUjianModel>> getJawabanUjianSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ujianId = prefs.getInt('ujianId');
      final userIdSiswa = prefs.getInt('userIdSiswa');

      final response = await supabase.rpc(
        'get_jawaban_ujian_siswa', // Anda perlu buat function ini di Supabase
        params: {'p_ujian_id': ujianId, 'p_user_id': userIdSiswa},
      );

      print("Data getJawabanUjianSiswa dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => JawabanUjianModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getJawabanUjianSiswa: $e");
      return [];
    }
  }
}
