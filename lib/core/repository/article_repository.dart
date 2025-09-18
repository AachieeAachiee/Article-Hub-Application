

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
import 'package:rimes_interview_projects/core/netwoks/db_helper.dart';
import 'package:rimes_interview_projects/core/netwoks/fcm.dart';

class ArticleRepository {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final DBHelper _db = DBHelper();

  Stream<List<Article>> articlesStream() {
    return _fire
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Article.fromFirestore(d.data(), d.id)).toList());
  }

  Future<List<Article>> fetchRemoteOnce() async {
    final snap = await _fire
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();
    final list =
        snap.docs.map((d) => Article.fromFirestore(d.data(), d.id)).toList();
    for (final a in list) {
      await _db.insertOrReplaceArticle(a).catchError((_) {});
    }
    return list;
  }

  Future<void> createArticle(Article a) async {
  // Save to Firestore
  final docRef = await FirebaseFirestore.instance.collection('articles').add({
    'authorId': a.authorId,
    'authorName': a.authorName,
    'title': a.title,
    'body': a.body,
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Save to local cache
  await _db.insertOrReplaceArticle(a);

  // Get all user tokens except creator
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  final tokens = snapshot.docs
      .where((doc) => doc.id != a.authorId) // exclude creator
      .map((doc) => doc['fcmToken'] as String?)
      .where((t) => t != null)
      .toList();

  if (tokens.isEmpty) return;

  // Send push to each token
  final fcm = FCMService(projectId: "com.example.rimes_interview_projects");
  for (final token in tokens) {
    await fcm.sendPush(
      title: "New Article Posted",
      body: "${a.authorName} posted \"${a.title}\"",
      token: token!,
      articleId: docRef.id,
    );
  }
}
 


  Future<void> updateArticle(String id, String title, String body) async {
    await _fire.collection('articles').doc(id).update({
      'title': title,
      'body': body,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteArticle(String id) async {
    await _fire.collection('articles').doc(id).delete();
    await _db.deleteCachedArticle(id);
  }

  Future<List<Article>> getCachedArticles() async =>
      await _db.getAllCachedArticles();

  Future<Article?> getCachedById(String id) async =>
      await _db.getCachedArticleById(id);

  Future<void> cacheArticle(Article a) async =>
      await _db.insertOrReplaceArticle(a);
}





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
// import 'package:rimes_interview_projects/core/netwoks/db_helper.dart';


// class ArticleRepository {
//   final FirebaseFirestore _fire = FirebaseFirestore.instance;
//   final DBHelper _db = DBHelper();

//   Stream<List<Article>> articlesStream() {
//     return _fire.collection('articles')
//       .orderBy('createdAt', descending: true)
//       .snapshots()
//       .map((snap) => snap.docs.map((d) => Article.fromFirestore(d.data(), d.id)).toList());
//   }

//   Future<List<Article>> fetchRemoteOnce() async {
//     final snap = await _fire.collection('articles').orderBy('createdAt', descending: true).get();
//     final list = snap.docs.map((d) => Article.fromFirestore(d.data(), d.id)).toList();
//     for (final a in list) {
//       await _db.insertOrReplaceArticle(a).catchError((_) {});
//     }
//     return list;
//   }

//   Future<void> createArticle(Article a) async {
//     final doc = _fire.collection('articles').doc();
//     // write serverTimestamp for server, but also cache optimistic local article
//     await doc.set({
//       'title': a.title,
//       'body': a.body,
//       'authorId': a.authorId,
//       'authorName': a.authorName,
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//     // optimistic local cache (use now so user sees it instantly)
//     await _db.insertOrReplaceArticle(a);
//   }

//   Future<void> updateArticle(String id, String title, String body) async {
//     await _fire.collection('articles').doc(id).update({
//       'title': title,
//       'body': body,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> deleteArticle(String id) async {
//     await _fire.collection('articles').doc(id).delete();
//     await _db.deleteCachedArticle(id);
//   }

//   Future<List<Article>> getCachedArticles() async => await _db.getAllCachedArticles();
//   Future<Article?> getCachedById(String id) async => await _db.getCachedArticleById(id);
//   Future<void> cacheArticle(Article a) async => await _db.insertOrReplaceArticle(a);
// }


