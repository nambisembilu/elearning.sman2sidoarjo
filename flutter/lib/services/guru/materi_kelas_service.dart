// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:elearning_sman2sidoarjo/services/guru/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/materi_kelas_model.dart';

class MateriKelasService {
  final SupabaseClient supabase;

  MateriKelasService(this.supabase);

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

  Future<MateriKelasResponse> getMateriKelas({
    int page = 1,
    int? semesterId,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_materi_kelas',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_semester_id': semesterId,
          'p_search': search,
        },
      );

      // print("Data materi kelas dari Supabase: $response");

      if (response == null) {
        return MateriKelasResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return MateriKelasResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return MateriKelasResponse.fromJson(response);
      }

      return MateriKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getMateriKelas: $e");
      return MateriKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<bool> addMateriKelas({
    required String judul,
    required int lingkupMateriId,
    required String deskripsi,
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
      final files = await storage.list(path: 'materi');
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
              'materi/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
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
                'add_materi_kelas_new',
                params: {
                  'p_kelas_mapel_id': kelasMapelId,
                  'p_lingkup_materi_id': lingkupMateriId,
                  'p_judul': judul,
                  'p_deskripsi': deskripsi,
                  'p_link_file_materi': uploadedUrls,
                },
              )
              as Map<String, dynamic>;

      final int materiId = response['materi_id'];

      print("✅ Response addMateriKelas : $response");

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
              title: 'Materi Baru',
              body: "'$judul'",
              route: '/dashboard/siswa/kelas/$kelasMapelId/detail-materi',
              routeGuru: '/dashboard/guru/kelas/$kelasMapelId/detail-materi',
              materiId: materiId.toString(),
              tugasId: '',
              ujianId: '',
              kelasMapelId: kelasMapelId.toString(),
            );

            print("✅ Notifikasi dikirim ke $nama");
          }
        } catch (e) {
          print("❌ Gagal proses penerima: $e");
          print("❌ Stack trace: $e");
        }
        // if (row['token'] != null && row['token'].toString().isNotEmpty) {
        //   await NotificationService(supabase).sendKomentarNotification(
        //     token: row['token'],
        //     title: 'Materi Baru',
        //     body: "'$judul'",
        //     route: '/dashboard/siswa/kelas/$kelasMapelId/detail-materi',
        //     materiId: materiId.toString(),
        //   );
        // }
      }

      return true;
    } catch (e) {
      print("❌ Error addMateriKelas: $e");
      return false;
    }
  }

  // Update fungsi updateMateriKelas untuk menyesuaikan dengan RPC
  Future<bool> updateMateriKelas({
    required int materiId,
    required String judul,
    required String deskripsi,
    required String status,
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
              'materi/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
          await storage.uploadBinary(fileName, fileBytes[i]);
          final publicUrl = storage.getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      // 3️⃣ Gabungkan file lama (yang disimpan) dan file baru (yang diupload)
      final List<Map<String, dynamic>> fileMateriJson = [
        ...filesToKeep, // tambahkan semua file lama yang masih disimpan
        for (String url in uploadedUrls)
          {'file_materi_id': null, 'link_file_materi': url}, // file baru
      ];

      // 4️⃣ Panggil RPC update_materi_kelas di Supabase
      final response = await supabase.rpc(
        'update_materi_kelas',
        params: {
          'p_materi_id': materiId,
          'p_judul': judul,
          'p_deskripsi': deskripsi,
          'p_status': status,
          'p_file_materi': fileMateriJson,
        },
      );

      print("Response updateMateriKelas: $response");
      return true;
    } catch (e) {
      print("Error updateMateriKelas: $e");
      return false;
    }
  }

  Future<void> deleteMateriKelas({
    required int materiId,
    required List<String> filesToDelete,
  }) async {
    try {
      for (String fileUrl in filesToDelete) {
        await deleteFileFromStorage(fileUrl);
      }

      final response = await supabase.rpc(
        'delete_materi_kelas',
        params: {'p_materi_id': materiId},
      );

      if (response == null) {
        throw Exception('Failed to delete materi');
      }

      print("Response deleteMateri: $response");
    } catch (e) {
      print("Error deleteMateri: $e");
      rethrow;
    }
  }

  Future<void> updateStatusMateriKelas({
    required int materiId,
    required String statusMateri,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_status_materi_kelas',
        params: {'p_materi_id': materiId, 'p_status': statusMateri},
      );

      if (response == null) {
        throw Exception('Failed to update_status_materi_kelas');
      }

      print("Response update_status_materi_kelas: $response");
    } catch (e) {
      print("Error update_status_materi_kelas: $e");
      rethrow;
    }
  }

  Future<List<MateriKelas>> getDetailMateri({required int materiId}) async {
    try {
      final response = await supabase.rpc(
        'get_detail_materi',
        params: {'p_materi_id': materiId},
      );

      if (response == null) {
        throw Exception('Failed to getDetailMateri');
      }

      print("Response getDetailMateri: $response");

      final List<dynamic> data = response as List<dynamic>;
      final List<MateriKelas> materiList = data
          .map((e) => MateriKelas.fromJson(e as Map<String, dynamic>))
          .toList();

      return materiList;
    } catch (e) {
      print("Error getDetailMateri: $e");
      rethrow;
    }
  }
}
