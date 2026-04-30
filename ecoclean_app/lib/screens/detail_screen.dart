import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isFav = widget.report.favoriteBy.contains(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rincian Laporan"),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () {
              DatabaseService.toggleFavorite(widget.report.id!, uid!, !isFav);
              setState(() {
                if (isFav)
                  widget.report.favoriteBy.remove(uid);
                else
                  widget.report.favoriteBy.add(uid);
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
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    widget.report.category!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.report.description!),
                  const Divider(height: 30),
                  Text(
                    "Lokasi: ${widget.report.latitude}, ${widget.report.longitude}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Komentar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                            title: Text(
                              d['userName'],
                              style: const TextStyle(
                                fontSize: 12,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Tambah komentar...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      DatabaseService.addComment(
                        widget.report.id!,
                        FirebaseAuth.instance.currentUser!.displayName!,
                        _commentController.text,
                      );
                      _commentController.clear();
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
