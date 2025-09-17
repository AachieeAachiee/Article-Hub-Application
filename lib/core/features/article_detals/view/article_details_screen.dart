import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/article_editor_screen/view/article_editor_screen.dart';
import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
import '../../article_list/viewmodel/article_viewmodel.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String articleId;
  const ArticleDetailScreen({required this.articleId, super.key});

  Future<void> _confirmDelete(
      BuildContext context, Article article, String articleId) async {
    final cur = FirebaseAuth.instance.currentUser;
    if (cur == null || cur.uid != article.authorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authorized to delete')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Delete this article?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      await Provider.of<ArticlesViewModel>(context, listen: false)
          .deleteArticle(articleId);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .doc(articleId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Article not found')),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final article = Article.fromFirestore(data, snap.data!.id);

        final curUid = FirebaseAuth.instance.currentUser?.uid;
        final isAuthor = curUid != null && curUid == article.authorId;

        return Scaffold(
          appBar: AppBar(
            title: Text(article.title),
            actions: [
              if (isAuthor)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ArticleEditorScreen(editingArticle: article),
                    ),
                  ),
                ),
              if (isAuthor)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      _confirmDelete(context, article, article.id),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text(
                            article.authorName.isNotEmpty
                                ? article.authorName[0].toUpperCase()
                                : "?",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(article.authorName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text(
                          DateFormat.yMMMd().format(article.createdAt),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(article.body,
                        style: const TextStyle(fontSize: 16, height: 1.5)),
                  ]),
            ),
          ),
        );
      },
    );
  }
}