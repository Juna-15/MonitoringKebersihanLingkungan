import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Koleksi Favorit",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Report>>(
        stream: DatabaseService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          
          final favReports =
              snapshot.data
                  ?.where((r) => r.favoriteBy.contains(uid))
                  .toList() ??
              [];

          if (favReports.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: favReports.length,
            itemBuilder: (context, i) {
              return _buildFavoriteCard(context, favReports[i], uid!, isDark);
            },
          );
        },
      ),
    );
  }

  
  Widget _buildFavoriteCard(
    BuildContext context,
    Report report,
    String uid,
    bool isDark,
  ) {
    String formattedDate = report.createdAt != null
        ? DateFormat('dd MMM yyyy').format(report.createdAt!.toDate())
        : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(report: report)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                
                Hero(
                  tag: 'fav-${report.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: report.image != null
                        ? Image.memory(
                            base64Decode(report.image!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.green.shade50,
                            child: const Icon(Icons.image, color: Colors.green),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.category ?? "Umum",
                        style: GoogleFonts.urbanist(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: GoogleFonts.urbanist(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () {
                    DatabaseService.toggleFavorite(report.id!, uid, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Dihapus dari Koleksi"),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Koleksi Masih Kosong",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Simpan laporan penting untuk\nmemantau perkembangannya nanti.",
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
