import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/article_list/viewmodel/article_viewmodel.dart';
import 'package:rimes_interview_projects/core/features/article_detals/view/article_details_screen.dart';
import 'package:rimes_interview_projects/core/features/article_editor_screen/view/article_editor_screen.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';
import 'package:rimes_interview_projects/core/features/users/view/user_profilescreen.dart';

class ArticleHomeScreen extends StatelessWidget {
  const ArticleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ArticlesViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Articles"),
        centerTitle: true,
        actions: [
          if (!vm.online)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.cloud_off, color: Colors.orange),
            ),


IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        onPressed: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final user = RegisterModels(
              uid: currentUser.uid,
              username: currentUser.displayName ?? "Unknown",
              email: currentUser.email ?? "",
              phone: "",      
              position: "",    
              country: "",     
              createAt: DateTime.now(),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(user: user),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No logged-in user")),
            );
          }
        },
      ),
    

            
        ],


      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.refresh,
              child: vm.articles.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No articles yet")),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: vm.articles.length,
                      itemBuilder: (context, i) {
                        final a = vm.articles[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ArticleDetailScreen(articleId: a.id),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    a.body.length > 100
                                        ? "${a.body.substring(0, 100)}..."
                                        : a.body,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        child: Text(
                                          a.authorName.isNotEmpty
                                              ? a.authorName[0].toUpperCase()
                                              : "?",
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        a.authorName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(a.createdAt),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ArticleEditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
