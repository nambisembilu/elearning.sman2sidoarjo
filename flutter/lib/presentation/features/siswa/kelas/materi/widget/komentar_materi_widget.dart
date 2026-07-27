import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../models/siswa/komentar_model.dart';
import '../../../../../controllers/siswa/komentar_materi/komentar_materi_riverpod.dart';

class KomentarMateriWidget extends ConsumerStatefulWidget {
  final bool isExpanded;

  const KomentarMateriWidget({super.key, required this.isExpanded});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KomentarMateriWidgetState();
}

class _KomentarMateriWidgetState extends ConsumerState<KomentarMateriWidget> {
  TextEditingController komentarController = TextEditingController();
  late ScrollController _scrollController;
  // bool _showLoadMore = false;
  late int userId;
  bool _isLoadingOlder = false;
  bool _initialScrollDone = false;
  bool _shouldScrollToBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadUserId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('user_id');

    setState(() {
      userId = int.parse(userid!);
    });
  }

  void _scrollListener() {
    // Scroll ke ATAS (load older comments) - dekat dengan posisi 0
    if (_scrollController.position.pixels <= 50 && !_isLoadingOlder) {
      final notifier = ref.read(komentarMateriRiverpodProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingOlder) {
        setState(() {
          _isLoadingOlder = true;
        });

        notifier.loadOlder().then((_) {
          if (mounted) {
            setState(() {
              _isLoadingOlder = false;
            });
          }
        });
      }
    }
  }

  // Fungsi untuk scroll ke bawah (ke komentar terbaru)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final komentarState = ref.watch(komentarMateriRiverpodProvider);
    final notifier = ref.read(komentarMateriRiverpodProvider.notifier);

    // Auto-scroll ke bawah ketika data pertama kali dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _shouldScrollToBottom &&
          komentarState.hasValue &&
          _scrollController.hasClients &&
          !_initialScrollDone) {
        final itemCount = komentarState.value?.length ?? 0;
        if (itemCount > 0) {
          _scrollToBottom();
          _initialScrollDone = true;
          _shouldScrollToBottom = false;
        }
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Symbols.people, size: 20),
              SizedBox(width: 8),
              Text(
                "Komentar kelas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 🔹 Area komentar scrollable dengan tinggi fixed
          Container(
            // height: widget.isExpanded ? 400 : 400,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(12),
            child: komentarState.when(
              data: (komentarList) {
                if (komentarList.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada komentar.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // Load older comments ketika scroll ke ATAS
                    if (scrollInfo.metrics.pixels <= 50 &&
                        notifier.hasMore &&
                        !notifier.isLoadingOlder &&
                        !_isLoadingOlder) {
                      setState(() {
                        _isLoadingOlder = true;
                      });

                      notifier.loadOlder().then((_) {
                        if (mounted) {
                          setState(() {
                            _isLoadingOlder = false;
                          });
                        }
                      });
                    }
                    return false;
                  },
                  child: Column(
                    children: [
                      // Loading indicator untuk older comments (di ATAS)
                      if (notifier.isLoadingOlder || _isLoadingOlder)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: komentarList.length,
                          itemBuilder: (context, index) {
                            final komentar = komentarList[index];
                            return _buildKomentarItem(komentar, context);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Symbols.error, color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      "Gagal memuat komentar",
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => notifier.resetAndFetch(),
                      child: const Text("Coba lagi"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    controller: komentarController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "Masukkan komentar...",
                      hintStyle: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () async {
                    if (komentarController.text.trim().isNotEmpty) {
                      final notifier = ref.read(
                        komentarMateriRiverpodProvider.notifier,
                      );
                      final success = await notifier.addKomentar(
                        komentar: komentarController.text.trim(),
                      );
                      if (success && mounted) {
                        komentarController.clear();

                        // Set flag untuk auto-scroll ke bawah
                        _shouldScrollToBottom = true;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Komentar berhasil ditambahkan'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menambahkan komentar'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Symbols.send, color: Colors.white),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKomentarItem(Komentar komentar, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        komentar.username.isNotEmpty
                            ? komentar.username[0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            komentar.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            komentar.waktuKomentar,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Menu button untuk hapus
              if (userId == komentar.userId)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Symbols.more_vert,
                    size: 18,
                    color: Colors.grey,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Symbols.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final notifier = ref.read(
                        komentarMateriRiverpodProvider.notifier,
                      );
                      final success = await notifier.deleteKomentar(
                        komentarId: komentar.komentarId,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Komentar berhasil dihapus'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menghapus komentar'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            komentar.komentar,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
