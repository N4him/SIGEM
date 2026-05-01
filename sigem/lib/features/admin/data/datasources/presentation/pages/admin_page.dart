import 'package:flutter/material.dart';
import 'package:sigem/features/admin/data/datasources/presentation/pages/monitors_tab.dart';
import 'package:sigem/features/admin/data/datasources/presentation/pages/reports_tab.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Panel Admin'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Monitores'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Reportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MonitorsTab(),
          ReportsTab(),
        ],
      ),
    );
  }
}