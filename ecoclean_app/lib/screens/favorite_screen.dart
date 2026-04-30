import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../widgets/post_list_item.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Favorit")),
      body: StreamBuilder(
        stream: DatabaseService.getReports(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final favs = snap.data!
              .where((r) => r.favoriteBy.contains(uid))
              .toList();
          if (favs.isEmpty)
            return const Center(child: Text("Belum ada laporan favorit."));
          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(favs[i].category!),
              subtitle: Text(favs[i].description!, maxLines: 1),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(report: favs[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
