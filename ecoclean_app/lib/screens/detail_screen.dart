import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import 'map_view_screen.dart'; // Pastikan file ini sudah Anda buat

class DetailScreen extends StatefulWidget {
  final Report report;
  const DetailScreen({super.key, required this.report});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _commentController = TextEditingController();

  // 1. Fungsi Buka Google Maps (Eksternal)
  Future<void> _openGoogleMaps() async {
    final lat = widget.report.latitude;
    final lng = widget.report.longitude;
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka Google Maps")),
        );
      }
    }
  }

  // 2. Fungsi Share Laporan
  void _shareReport() {
    final lat = widget.report.latitude;
    final lng = widget.report.longitude;
    final mapLink = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    final shareContent =
        "🌱 *Laporan EcoClean*\n\n"
        "Kategori: ${widget.report.category}\n"
        "Deskripsi: ${widget.report.description}\n\n"
        "📍 Lokasi Kejadian:\n$mapLink";

    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isFav = widget.report.favoriteBy.contains(uid);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format Tanggal menggunakan Intl
    String formattedDate = widget.report.createdAt != null
        ? DateFormat(
            'dd MMM yyyy, HH:mm',
          ).format(widget.report.createdAt!.toDate())
        : "-";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rincian Laporan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareReport,
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
            ),
            onPressed: () {
              DatabaseService.toggleFavorite(widget.report.id!, uid!, !isFav);
              setState(() {
                if (isFav) {
                  widget.report.favoriteBy.remove(uid);
                } else {
                  widget.report.favoriteBy.add(uid);
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SEKSI GAMBAR ---
                  if (widget.report.image != null)
                    Image.memory(
                      base64Decode(widget.report.image!),
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- KATEGORI & WAKTU ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Text(
                                widget.report.category ?? "Umum",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // --- DESKRIPSI ---
                        const Text(
                          "Keterangan Kondisi:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.report.description ?? "Tidak ada deskripsi",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- SEKSI LOKASI (REVISI: KOORDINAT + 2 TOMBOL MAP) ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.redAccent,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Titik Koordinat GPS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${widget.report.latitude}, ${widget.report.longitude}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  // TOMBOL: Flutter Map (Internal)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapViewScreen(
                                              latitude: double.parse(
                                                widget.report.latitude!,
                                              ),
                                              longitude: double.parse(
                                                widget.report.longitude!,
                                              ),
                                              category: widget.report.category!,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.map_outlined,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        "LIHAT MAP",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // TOMBOL: Google Maps (Eksternal)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.blue.shade700,
                                        ),
                                        foregroundColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: _openGoogleMaps,
                                      icon: const Icon(
                                        Icons.navigation_outlined,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        "G-MAPS",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(),

                        // --- SEKSI KOMENTAR ---
                        const Text(
                          "Komentar Masyarakat",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder(
                          stream: DatabaseService.getComments(
                            widget.report.id!,
                          ),
                          builder: (context, snap) {
                            if (!snap.hasData) return const SizedBox();
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snap.data!.docs.length,
                              itemBuilder: (context, i) {
                                var d = snap.data!.docs[i];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 0,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green.shade100,
                                      child: Text(
                                        d['userName'][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      d['userName'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      d['text'],
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BAR INPUT KOMENTAR (FIXED BOTTOM) ---
          Container(
            padding: EdgeInsets.fromLTRB(
              15,
              10,
              15,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Tambah tanggapan...",
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      DatabaseService.addComment(
                        widget.report.id!,
                        FirebaseAuth.instance.currentUser!.displayName ??
                            "Anonim",
                        _commentController.text,
                      );
                      _commentController.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
