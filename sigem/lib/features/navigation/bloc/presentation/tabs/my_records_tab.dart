import 'package:flutter/material.dart';
import 'package:sigem/features/attendance/presentation/pages/my_records_page.dart';

class MyRecordsTab extends StatefulWidget {
  const MyRecordsTab({super.key});

  @override
  State<MyRecordsTab> createState() => _MyRecordsTabState();
}

class _MyRecordsTabState extends State<MyRecordsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // obligatorio
    return const MyRecordsPage();
  }
}