import 'package:special_characters/model/destress_tech_model.dart';

abstract class StressReliefView {
  void showArticles(List<Article> entries);
  void showError(String message);
}

class ArticlesPresenter {
  final StressReliefView view;
  final StressReliefFirebaseService _articlesService =
      StressReliefFirebaseService();

  ArticlesPresenter(this.view);

  void loadArticles() async {
    try {
      List<Article> entries = await _articlesService.getArticles();
      view.showArticles(entries);
    } catch (e) {
      view.showError("Failed to load articles");
    }
  }

  Future<void> addArticle(String title, String text) async {
    Article article = Article(
        id: '', articleName: title, articleContents: text, isFavorite: false);
    await _articlesService.addArticle(article);
  }

  Future<void> editArticle(Article article) async {
    await _articlesService.editArticle(article);
  }

  Future<void> deleteArticle(Article article) async {
    await _articlesService.deleteArticle(article);
    loadArticles();
  }
}
