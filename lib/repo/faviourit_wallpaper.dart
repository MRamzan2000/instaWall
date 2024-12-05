import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../modal/modal.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Images> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(
        child: Text('No favorites yet!'),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final wallpaper = favorites[index];

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: wallpaper.imagePotraitPath,
              errorWidget: (context, url, error) =>
              const Icon(Icons.error),
            ),
          );
        },
      ),
    );
  }
}
