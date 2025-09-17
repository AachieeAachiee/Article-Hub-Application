import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
import 'package:rimes_interview_projects/core/repository/article_repository.dart';

class ArticlesViewModel extends ChangeNotifier {
  final ArticleRepository _repo = ArticleRepository();
  List<Article> articles = [];
  bool isLoading = false;
  bool online = true;

  StreamSubscription<List<Article>>? _streamSub;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  ArticlesViewModel() {
    _init();
  }

  void setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  Future<void> _init() async {
    setLoading(true);

    // Initial connectivity check
    final conn = await Connectivity().checkConnectivity();
    online = conn.isNotEmpty && conn.first != ConnectivityResult.none;

    // Listen for connectivity changes
    _connSub =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      online = results.isNotEmpty && results.first != ConnectivityResult.none;
      notifyListeners();

      // If connection restored, refresh articles
      if (online) {
        refresh();
      }
    });

    try {
      if (online) {
        // First fetch to cache articles
        await _repo.fetchRemoteOnce();

        // Listen to remote changes
        _streamSub = _repo.articlesStream().listen((list) {
          articles = list;
          notifyListeners();
        });
      } else {
        // Load from cache if offline
        articles = await _repo.getCachedArticles();
        notifyListeners();
      }
    } catch (e) {
      // fallback to cache
      articles = await _repo.getCachedArticles();
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  Future<void> refresh() async {
    setLoading(true);
    try {
      await _repo.fetchRemoteOnce();
    } catch (e) {
      // ignore errors, fallback on cache
    }
    setLoading(false);
  }

  Future<void> createArticle(Article a) async {
    await _repo.createArticle(a);
    articles.add(a);
    notifyListeners();
  }

  Future<void> updateArticle(String id, String title, String body) async {
    await _repo.updateArticle(id, title, body);
    final index = articles.indexWhere((x) => x.id == id );
    if(index != -1){
      articles[index] = articles[index].copyWith(
        title:title,
        body: body,
        updatedAt:DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> deleteArticle(String id) async {
    await _repo.deleteArticle(id);
    articles.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }
}