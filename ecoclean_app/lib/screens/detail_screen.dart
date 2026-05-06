import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import '../models/report.dart';
import '../services/database_service.dart';

class DetailScreen extends StatefulWidget {
  final Report report;
  const DetailScreen({super.key, required this.report});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _commentController = TextEditingController();

  
  Future<void> _openGoogleMaps() async {
    final lat = widget.report.latitude;
    final lng = widget.report.longitude;
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka Google Maps")),
        );
      }
    }
  }

  
  void _shareReport() {
    final lat = widget.report.latitude;
    final lng = widget.report.longitude;
    final mapLink = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    final shareContent =
        "📢 *Laporan EcoClean*\n\n"
        "Kategori: ${widget.report.category}\n"
        "Deskripsi: ${widget.report.description}\n"
        "Lokasi: $mapLink";

    Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isFav = widget.report.favoriteBy.contains(uid);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    
    String formattedDate = widget.report.createdAt != null
        ? DateFormat(
            'dd MMM yyyy, HH:mm',
          ).format(widget.report.createdAt!.toDate())
        : "-";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rincian Laporan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareReport,
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
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
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.report.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(
                        base64Decode(widget.report.image!),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.report.category!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.report.description!,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),

                  const Divider(height: 40),

                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Titik Koordinat:",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${widget.report.latitude}, ${widget.report.longitude}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _openGoogleMaps,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text("LIHAT DI GOOGLE MAPS"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Komentar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  StreamBuilder(
                    stream: DatabaseService.getComments(widget.report.id!),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snap.data!.docs.length,
                        itemBuilder: (context, i) {
                          var d = snap.data!.docs[i];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              d['userName'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(d['text']),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
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
                      hintText: "Tambah komentar...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
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
                  icon: const Icon(Icons.send, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
