import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/article_list/model/article.dart';
import 'package:rimes_interview_projects/core/features/article_list/view/article_home_screen.dart';
import 'package:rimes_interview_projects/core/features/article_list/viewmodel/article_viewmodel.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArticleEditorScreen extends StatefulWidget {
  final Article? editingArticle;
  const ArticleEditorScreen({this.editingArticle, super.key});
  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  Timer? _debounce;
  int wordCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editingArticle != null) {
      titleCtrl.text = widget.editingArticle!.title;
      bodyCtrl.text = widget.editingArticle!.body;
      wordCount = _countWords(bodyCtrl.text);
    }
    bodyCtrl.addListener(_onBodyChanged);
  }

  void _onBodyChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => wordCount = _countWords(bodyCtrl.text));
    });
  }

  int _countWords(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    titleCtrl.dispose();
    bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleCtrl.text.trim();
    final body = bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and body required')));
      return;
    }

    final vm = Provider.of<ArticlesViewModel>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final name = FirebaseAuth.instance.currentUser?.email ?? 'Unknown';

try{
    if (widget.editingArticle == null) {
      final id = const Uuid().v4();
      final now = DateTime.now();
      final a = Article(
        id: id, title: title, body: body, authorId: uid, authorName: name, createdAt: now, updatedAt: now);
      await vm.createArticle(a);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article Saved Successfully')));
    
    
    } else {
      await vm.updateArticle(widget.editingArticle!.id, title, body);
    

    if (!mounted) return;

       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article Updated Successfully')));

    }
    Future.delayed(const Duration(milliseconds: 300),(){
    if(mounted) Navigator.pop(context,true);
  });
   
  }catch(e){
    if(!mounted) return;
   // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content:Text('Error:$e')),);
  //  print(e);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ArticleHomeScreen()));
  }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingArticle != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Article' : 'New Article')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          Expanded(child: TextField(controller: bodyCtrl, maxLines: null, expands: true, decoration: const InputDecoration(labelText: 'Body'))),
          const SizedBox(height: 8),
          Row(children: [
            Text('Word count: $wordCount'),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: Text(isEditing ? 'Update' : 'Save')),
          ]),
        ]),
      ),
    );
  }
}