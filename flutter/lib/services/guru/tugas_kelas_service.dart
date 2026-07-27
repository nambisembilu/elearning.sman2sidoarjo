// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/daftar_pengumpulan_tugas.dart';
import '../../models/guru/pengumpulan_tugas_model.dart';
import '../../models/guru/tugas_kelas_model.dart';
import 'notification_service.dart';

class TugasKelasService {
  final SupabaseClient supabase;

  TugasKelasService(this.supabase);

  // Fungsi untuk extract path dari URL Supabase
  String _extractPathFromUrl(String publicUrl) {
    try {
      final uri = Uri.parse(publicUrl);
      // Path di Supabase storage biasanya setelah '/object/public/'
      final pathSegments = uri.pathSegments;
      final index = pathSegments.indexOf('elearning');
      if (index != -1 && index + 1 < pathSegments.length) {
        return pathSegments.sublist(index + 1).join('/');
      }
      return '';
    } catch (e) {
      print("Error extracting path from URL: $e");
      return '';
    }
  }

  // Fungsi untuk menghapus file dari storage
  Future<bool> deleteFileFromStorage(String fileUrl) async {
    try {
      final path = _extractPathFromUrl(fileUrl);
      if (path.isEmpty) {
        print("Cannot extract path from URL: $fileUrl");
        return false;
      }

      await supabase.storage.from('elearning').remove([path]);
      print("File deleted successfully: $path");
      return true;
    } catch (e) {
      print("Error deleting file from storage: $e");
      return false;
    }
  }

  Future<TugasKelasResponse> getTugasKelas({
    int page = 1,
    int? semesterId,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_tugas_kelas',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_semester_id': semesterId,
          'p_search': search,
        },
      );

      // print("Data tugas kelas dari Supabase: $response");

      if (response == null) {
        return TugasKelasResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      if (response is String) {
        return TugasKelasResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return TugasKelasResponse.fromJson(response);
      }

      return TugasKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getTugasKelas: $e");
      return TugasKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<bool> addTugasKelas({
    required String judul,
    required int tujuanPembelajaranId,
    required String deskripsi,
    required String deadline,
    required String statusTugas,
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');
    final storage = supabase.storage.from('elearning');
    const maxStorageSize = 50 * 1024 * 1024; // 50MB
    List<String> uploadedUrls = [];

    try {
      // 🔹 Langkah 1: Hitung total penggunaan storage saat ini
      final files = await storage.list(path: 'tugas');
      int currentUsage = 0;
      for (final file in files) {
        final size = file.metadata?['size'];
        if (size != null) currentUsage += (size as num).toInt();
      }

      // 🔹 Langkah 2: Hitung total ukuran file baru yang mau diupload
      final totalUploadSize = fileBytes.fold<int>(
        0,
        (sum, b) => sum + b.length,
      );

      // 🔹 Langkah 3: Cek apakah melebihi kapasitas 50MB
      if (currentUsage + totalUploadSize > maxStorageSize) {
        print(
          '🚫 Kapasitas storage Supabase tidak cukup untuk upload file baru.',
        );
        print(
          '📦 Total penggunaan saat ini: ${(currentUsage / 1024 / 1024).toStringAsFixed(2)} MB',
        );
        print(
          '📂 Total ukuran upload baru: ${(totalUploadSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
        return false;
      }

      // 🔹 Langkah 4: Upload file satu per satu
      if (fileBytes.isNotEmpty && fileNames.isNotEmpty) {
        for (int i = 0; i < fileBytes.length; i++) {
          final fileName =
              'tugas/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
          try {
            await storage.uploadBinary(fileName, fileBytes[i]);
            final publicUrl = storage.getPublicUrl(fileName);
            uploadedUrls.add(publicUrl);
          } catch (uploadError) {
            print('⚠️ Gagal upload ${fileNames[i]}: $uploadError');
            return false;
          }
        }
      }

      // 🔹 Langkah 5: Simpan data ke database lewat RPC Supabase
      final response =
          await supabase.rpc(
                'add_tugas_kelas_new',
                params: {
                  'p_kelas_mapel_id': kelasMapelId,
                  'p_tujuan_pembelajaran_id': tujuanPembelajaranId,
                  'p_judul': judul,
                  'p_deskripsi': deskripsi,
                  'p_deadline': deadline,
                  'p_status_tugas': statusTugas,
                  'p_link_file_tugas': uploadedUrls,
                },
              )
              as Map<String, dynamic>;

      final int tugasId = response['tugas_id'];

      print("✅ Response addTugasKelas : $response");

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
              title: 'Tugas Baru',
              body: "'$judul'",
              route: '/dashboard/siswa/kelas/$kelasMapelId/detail-tugas',
              routeGuru: '/dashboard/guru/kelas/$kelasMapelId/detail-tugas',
              materiId: '',
              tugasId: tugasId.toString(),
              ujianId: '',
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
      print("❌ Error addTugasKelas: $e");
      return false;
    }
  }

  // Update fungsi updateTugasKelas untuk menyesuaikan dengan RPC
  Future<bool> updateTugasKelas({
    required int tugasId,
    required String judul,
    required String deskripsi,
    // required int maxJmlPengumpulan,
    required String deadline,
    required String statusTugas,
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
    required List<String> filesToDelete, // URL file yang dihapus
    required List<Map<String, dynamic>> filesToKeep, // file lama yang tetap
  }) async {
    final storage = supabase.storage.from('elearning');
    List<String> uploadedUrls = [];

    try {
      // 1️⃣ Hapus file yang ditandai untuk dihapus
      for (String fileUrl in filesToDelete) {
        await deleteFileFromStorage(fileUrl);
      }

      // 2️⃣ Upload file baru (jika ada)
      if (fileBytes.isNotEmpty && fileNames.isNotEmpty) {
        for (int i = 0; i < fileBytes.length; i++) {
          final fileName =
              'tugas/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
          await storage.uploadBinary(fileName, fileBytes[i]);
          final publicUrl = storage.getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      // 3️⃣ Gabungkan file lama (yang disimpan) dan file baru (yang diupload)
      final List<Map<String, dynamic>> fileTugasJson = [
        ...filesToKeep, // tambahkan semua file lama yang masih disimpan
        for (String url in uploadedUrls)
          {'file_tugas_id': null, 'link_file_tugas': url}, // file baru
      ];

      // 4️⃣ Panggil RPC update_tugas_kelas di Supabase
      final response = await supabase.rpc(
        'update_tugas_kelas_2',
        params: {
          'p_tugas_id': tugasId,
          'p_judul': judul,
          'p_deskripsi': deskripsi,
          'p_deadline': deadline,
          'p_status_tugas': statusTugas,
          // 'p_max_jml_pengumpulan': maxJmlPengumpulan,
          'p_file_tugas': fileTugasJson,
        },
      );

      print("Response updateTugasKelas: $response");
      return true;
    } catch (e) {
      print("Error updateTugasKelas: $e");
      return false;
    }
  }

  Future<void> deleteTugasKelas({
    required int tugasId,
    required List<String> filesToDelete,
  }) async {
    try {
      for (String fileUrl in filesToDelete) {
        await deleteFileFromStorage(fileUrl);
      }

      final response = await supabase.rpc(
        'delete_tugas_kelas',
        params: {'p_tugas_id': tugasId},
      );

      if (response == null) {
        throw Exception('Failed to delete tugas');
      }

      print("Response deleteTugas: $response");
    } catch (e) {
      print("Error deleteTugas: $e");
      rethrow;
    }
  }

  Future<List<TugasKelas>> getDetailTugas({required int tugasId}) async {
    try {
      final response = await supabase.rpc(
        'get_detail_tugas',
        params: {'p_tugas_id': tugasId},
      );

      if (response == null) {
        throw Exception('Failed to getDetailTugas');
      }

      print("Response getDetailTugas: $response");

      final List<dynamic> data = response as List<dynamic>;
      final List<TugasKelas> tugasList = data
          .map((e) => TugasKelas.fromJson(e as Map<String, dynamic>))
          .toList();

      return tugasList;
    } catch (e) {
      print("Error getDetailTugas: $e");
      rethrow;
    }
  }

  Future<DaftarPengumpulanTugasResponse> getDaftarPengumpulanTugas({
    int page = 1,
    String? search,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');
      final tugasId = prefs.getInt('tugasId');

      final response = await supabase.rpc(
        'get_daftar_pengumpulan_tugas_4',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_tugas_id': tugasId,
          'p_page': page,
          'p_search': search,
          'p_limit': limit,
        },
      );

      print("Data pengumpulan tugas kelas dari Supabase: $response");

      if (response == null) {
        return DaftarPengumpulanTugasResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return DaftarPengumpulanTugasResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return DaftarPengumpulanTugasResponse.fromJson(response);
      }

      return DaftarPengumpulanTugasResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getDaftarPengumpulanTugas: $e");
      return DaftarPengumpulanTugasResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }

  Future<void> addNilaiTugas({
    required int pengumpulanTugasId,
    required double nilai,
    required String feedback,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_nilai_feedback_tugas',
        params: {
          'p_pengumpulan_tugas_id': pengumpulanTugasId,
          'p_nilai': nilai,
          'p_feedback': feedback,
        },
      );

      if (response == null) {
        throw Exception('Failed to add nilai tugas');
      }

      print("Response addNilaiTugas: $response");
    } catch (e) {
      print("Error addNilaiTugas: $e");
      rethrow;
    }
  }

  Future<PengumpulanTugasDetailModel> getDetailPengumpulanTugasSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pengumpulanTugasId = prefs.getInt('pengumpulanTugasId');

      print("Pengumpulan tugas id : $pengumpulanTugasId");

      final response = await supabase.rpc(
        'get_pengumpulan_tugas_siswa',
        params: {'p_pengumpulan_tugas_id': pengumpulanTugasId},
      );

      if (response == null) {
        throw Exception('Failed to getPengumpulanTugasSiswa');
      }

      print("Response getPengumpulanTugasSiswa: $response");

      // ✅ Response adalah Map, bukan List
      if (response is Map<String, dynamic>) {
        return PengumpulanTugasDetailModel.fromJson(response);
      } else {
        throw Exception('Unexpected response format: $response');
      }
    } catch (e) {
      print("Error getPengumpulanTugasSiswa: $e");
      rethrow;
    }
  }
}
