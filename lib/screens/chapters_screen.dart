import 'package:ekluvya_app/models/subject_model.dart';
import 'package:flutter/material.dart';

class ChaptersScreen extends StatefulWidget {
  final Subject subject;
  final String courseId;
  final String classId;

  const ChaptersScreen({
    super.key,
    required this.subject,
    required this.courseId,
    required this.classId,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chapters Screen'),
      ),
    );
  }
}
