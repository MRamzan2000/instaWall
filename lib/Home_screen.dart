import 'package:InstaWall/preview_page.dart';
import 'package:InstaWall/repo/faviourit_wallpaper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'modal/modal.dart';
import 'repo/repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Repository repo = Repository();
  late Future<List<Images>> imagesList;
  int pageNumber = 2;
  List<Images> favoriteWallpapers = [];

  @override
  void initState() {
    imagesList = repo.getImagesList(pageNumber: pageNumber);
    super.initState();
  }

  void toggleFavorite(Images wallpaper) {
    setState(() {
      if (favoriteWallpapers.contains(wallpaper)) {
        favoriteWallpapers.remove(wallpaper);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Favorites')),
        );
      } else {
        favoriteWallpapers.add(wallpaper);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Favorites')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:  SizedBox(
            height: 4.h,
            child: const Image(
              image: AssetImage("assets/appicon.png"),
              fit: BoxFit.cover,
            )),
        centerTitle: true,
        actions: [
          Padding(
            padding:  EdgeInsets.only(right: 1.h),
            child: IconButton(
              icon: Icon(Icons.favorite,size: 3.5.h,color: Colors.deepOrange,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FavoritesScreen(favorites: favoriteWallpapers),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: imagesList,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            return MasonryGridView.count(
              itemCount: snapshot.data?.length,
              shrinkWrap: true,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              crossAxisCount: 2,
              itemBuilder: (context, index) {
                final wallpaper = snapshot.data![index];

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        
                      Get.to(()=>PreviewPage(  imageId: wallpaper.imageID,
                        imageUrl: wallpaper.imagePotraitPath,))     ;
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: wallpaper.imagePotraitPath,
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          favoriteWallpapers.contains(wallpaper)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoriteWallpapers.contains(wallpaper)
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () {
                          toggleFavorite(wallpaper);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
    );
  }
}
