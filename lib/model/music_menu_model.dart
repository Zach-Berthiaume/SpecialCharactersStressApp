import 'package:cloud_firestore/cloud_firestore.dart';

class Playlist implements Comparable<Playlist> {
  final String id;
  String playlistName;
  List<Map<String, String>> songs;

  Playlist({
    required this.id,
    required this.playlistName,
    required this.songs,
  });

  Map<String, dynamic> toMap() {
    return {
      'playlistName': playlistName,
      'songs': songs,
    };
  }

  factory Playlist.fromMap(String id, Map<String, dynamic> data) {
    return Playlist(
      id: id,
      playlistName: data['playlistName'] ?? '',
      songs: (data['songs'] as List<dynamic>?)
              ?.map((song) => Map<String, String>.from(song))
              .toList() ??
          [],
    );
  }

  @override
  int compareTo(Playlist other) {
    return playlistName.compareTo(other.playlistName);
  }
}

class PlaylistFirebaseService {
  final CollectionReference playlistCollection =
      FirebaseFirestore.instance.collection('playlists');

  Future<List<Playlist>> getPlaylists() async {
    QuerySnapshot snapshot = await playlistCollection.get();
    return snapshot.docs
        .map((doc) => Playlist.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addPlaylist(Playlist playlist) async {
    await playlistCollection.add(playlist.toMap());
  }

  Future<void> editPlaylist(Playlist playlist) async {
    await playlistCollection.doc(playlist.id).update(playlist.toMap());
  }

  Future<void> deletePlaylist(String playlistId) async {
    await playlistCollection.doc(playlistId).delete();
  }
}

class Favorites implements Comparable<Favorites> {
  final String id;
  final String songName;
  final String songPath;

  Favorites({
    required this.id,
    required this.songName,
    required this.songPath,
  });

  factory Favorites.fromMap(String id, Map<String, dynamic> data) {
    return Favorites(
      id: id,
      songName: data['songName'] ?? '',
      songPath: data['songPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songName' : songName,
      'songPath' : songPath,
    };
  }

  @override
  int compareTo(Favorites other) {
    return id.compareTo(other.id);
  }
}

class FavoritesFireBaseService {
  final CollectionReference favoritesCollection =
    FirebaseFirestore.instance.collection('favorites');

    Future<List<Favorites>> getFavorites() async {
      QuerySnapshot snapshot = await favoritesCollection.get();
      return snapshot.docs.map((doc) => 
        Favorites.fromMap(doc.id, doc.data() 
        as Map<String, dynamic>)).toList();
    }

    Future<void> addFavorite(Favorites favorite) async {
      await favoritesCollection.add(favorite.toMap());
    }

    Future<void> deleteFavorite(String favoriteId) async {
      await favoritesCollection.doc(favoriteId).delete();
    }
}