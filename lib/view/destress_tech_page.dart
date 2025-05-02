import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/destress_tech_model.dart';
import 'package:special_characters/presenter/destress_tech_presenter.dart';
import 'package:special_characters/model/theme.dart';

class DestressTechPage extends StatefulWidget {
  const DestressTechPage({super.key});

  @override
  State<DestressTechPage> createState() => _DestressTechPageState();
}

class _DestressTechPageState extends State<DestressTechPage>
    implements StressReliefView {
  int currentPageIndex = 0;
  late ArticlesPresenter _presenter;
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = ArticlesPresenter(this);
    _presenter.loadArticles();
  }

  @override
  void showArticles(List<Article> entries) {
    setState(() {
      _articles = entries;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  void _refreshArticles() {
    setState(() {
      _presenter.loadArticles();
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color(0xFFFFF8E1),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  'Stress Relief Techniques',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _refreshArticles(),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.vertical,
                  children: [
                    _buildArticles(),
                  ],
                ),
              ),
            ),
            OverflowBar(
              spacing: -1000,
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      iconColor: isDarkMode ? Colors.white : Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border_outlined),
                      Text(
                        'Favorites',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => favorites()),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      iconColor: isDarkMode ? Colors.white : Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.shuffle),
                      Text(
                        'Random',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => displayArticle(
                          _articles[Random().nextInt(_articles.length)])),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      iconColor: isDarkMode ? Colors.white : Colors.black),
                  child: Column(
                    children: [
                      Icon(Icons.add_box_outlined),
                      Text(
                        'Add Article',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => addArticle()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticles() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Column(
        children: [
          Text(
            "Error: $_errorMessage",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    if (_articles.isEmpty) {
      return Column(
        children: [
          Text(
            "No entries yet, try creating one!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    //if not any of the cases above:
    //sort by recent edits
    // _articles.sort();
    return Column(
      children: [
        for (Article article in _articles) ...[
          _buildArticle(article),
        ],
      ],
    );
  }

  Padding _buildArticle(Article article) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  article.articleName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        onTap: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => displayArticle(article)),
      ),
    );
  }

  Dialog displayArticle(Article article) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    textAlign: TextAlign.center,
                    article.articleName,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      article.isFavorite = !article.isFavorite;
                      _presenter.editArticle(article);
                    case 2:
                      _presenter.deleteArticle(article);
                      Navigator.of(context, rootNavigator: true).pop();
                  }
                  _refreshArticles();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                            article.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.black),
                        SizedBox(width: 8),
                        Text('Favorite'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.black),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              textAlign: TextAlign.left,
              article.articleContents,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget favorites() {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Favorites',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              scrollDirection: Axis.vertical,
              children: [
                for (Article article in _articles) ...[
                  if (article.isFavorite) _buildArticle(article),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addArticle() {
    TextEditingController articleName = TextEditingController();
    TextEditingController articleContents = TextEditingController();
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Add Article',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: TextField(
              controller: articleName,
              decoration: InputDecoration(
                hintText: 'Enter Title',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: articleContents,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write article contents here',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: FilledButton(
                onPressed: () {
                  _presenter.addArticle(articleName.text, articleContents.text);
                  _refreshArticles();
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text('Add Article')),
          ),
        ],
      ),
    );
  }
}
