// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/siswa/pengumpulan_tugas_model.dart';
import '../../models/siswa/tugas_kelas_model.dart';

class TugasKelasService {
  final SupabaseClient supabase;

  TugasKelasService(this.supabase);

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

  Future<List<TugasKelas>> getDetailTugas({required int tugasId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      final response = await supabase.rpc(
        'get_detail_tugas_siswa_2',
        params: {'p_tugas_id': tugasId, 'p_user_id': int.parse(userId!)},
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

  Future<bool> updatePengumpulanTugas({
    required int pengumpulanTugasId,
    required String statusPengumpulan,
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
              'pengumpulan_tugas/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
          await storage.uploadBinary(fileName, fileBytes[i]);
          final publicUrl = storage.getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      // 3️⃣ Gabungkan file lama (yang disimpan) dan file baru (yang diupload)
      final List<Map<String, dynamic>> fileTugasJson = [
        ...filesToKeep, // tambahkan semua file lama yang masih disimpan
        for (String url in uploadedUrls)
          {'file_pengumpulan_tugas_id': null, 'link_file': url}, // file baru
      ];

      // 4️⃣ Panggil RPC update_tugas_kelas di Supabase
      final response = await supabase.rpc(
        'update_pengumpulan_tugas_2',
        params: {
          'p_pengumpulan_tugas_id': pengumpulanTugasId,
          'p_status_pengumpulan': statusPengumpulan,
          'p_file_pengumpulan_tugas': fileTugasJson,
        },
      );

      print("Response updatePengumpulanTugas: $response");
      return true;
    } catch (e) {
      print("Error updatePengumpulanTugas: $e");
      return false;
    }
  }

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

  Future<bool> addPengumpulanTugas({
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tugasId = prefs.getInt('tugasId');
    final userId = prefs.getString('user_id');
    final storage = supabase.storage.from('elearning');
    const maxStorageSize = 50 * 1024 * 1024; // 50MB
    List<String> uploadedUrls = [];

    try {
      // 🔹 Langkah 1: Hitung total penggunaan storage saat ini
      final files = await storage.list(path: 'pengumpulan_tugas');
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
              'pengumpulan_tugas/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
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
      final response = await supabase.rpc(
        'add_pengumpulan_tugas_siswa',
        params: {
          'p_user_id': userId,
          'p_tugas_id': tugasId,
          'p_link_file_pengumpulan_tugas': uploadedUrls,
        },
      );

      print("✅ Response addPengumpulanTugas : $response");
      return true;
    } catch (e) {
      print("❌ Error addPengumpulanTugas: $e");
      return false;
    }
  }

  Future<bool> ubahPengumpulanTugas({
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tugasId = prefs.getInt('tugasId');
    final userId = prefs.getString('user_id');
    final storage = supabase.storage.from('elearning');
    const maxStorageSize = 50 * 1024 * 1024; // 50MB
    List<String> uploadedUrls = [];

    try {
      // 🔹 Langkah 1: Hitung total penggunaan storage saat ini
      final files = await storage.list(path: 'pengumpulan_tugas');
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
              'pengumpulan_tugas/${DateTime.now().millisecondsSinceEpoch}_${fileNames[i]}';
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
      final response = await supabase.rpc(
        'update_pengumpulan_tugas',
        params: {
          'p_user_id': userId,
          'p_tugas_id': tugasId,
          'p_link_file_pengumpulan_tugas': uploadedUrls,
        },
      );

      print("✅ Response addPengumpulanTugas : $response");
      return true;
    } catch (e) {
      print("❌ Error addPengumpulanTugas: $e");
      return false;
    }
  }

  Future<List<PengumpulanTugasDetailModel>>
  getDetailPengumpulanTugasSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pengumpulanTugasId = prefs.getInt('pengumpulan_tugas_id');

      final response = await supabase.rpc(
        'get_pengumpulan_tugas_siswa',
        params: {'p_pengumpulan_tugas_id': pengumpulanTugasId},
      );

      if (response == null) {
        throw Exception('Failed to getPengumpulanTugasSiswa');
      }

      print("Response getPengumpulanTugasSiswa: $response");

      final List<dynamic> data = response as List<dynamic>;
      final List<PengumpulanTugasDetailModel> detailPengumpulanTugas = data
          .map(
            (e) =>
                PengumpulanTugasDetailModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      return detailPengumpulanTugas;
    } catch (e) {
      print("Error getPengumpulanTugasSiswa: $e");
      rethrow;
    }
  }
}
