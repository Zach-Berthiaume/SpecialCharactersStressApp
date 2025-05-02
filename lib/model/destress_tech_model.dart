import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  String articleName;
  String articleContents;
  bool isFavorite;

  Article(
      {required this.id,
      required this.articleName,
      required this.articleContents,
      required this.isFavorite});

  //conversion to firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': articleName,
      'contents': articleContents,
      'isFavorite': isFavorite,
    };
  }

  //conversion from firestore map to article
  factory Article.fromMap(String id, Map<String, dynamic> data) {
    return Article(
      id: id,
      articleName: data['name'] ?? '',
      articleContents: data['contents'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}

class StressReliefFirebaseService {
  final CollectionReference articlesCollection =
      FirebaseFirestore.instance.collection('stressReliefTechniques');
  //retrieve articles (Future to wait for articles to come in from database)
  Future<List<Article>> getArticles() async {
    //returns list of documentsnapshot objects within stressReliefTechniques collection
    QuerySnapshot snapshot = await articlesCollection.get();
    //creates iterable of articles objects:
    return snapshot.docs
        .map((doc) =>
            Article.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addArticle(Article article) async {
    await articlesCollection.add(article.toMap());
  }

  Future<void> editArticle(Article article) async {
    await articlesCollection.doc(article.id).update(article.toMap());
  }

  Future<void> deleteArticle(Article article) async {
    await articlesCollection.doc(article.id).delete();
  }
}
