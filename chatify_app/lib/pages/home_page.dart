import 'package:chatify_app/pages/profile_page.dart';
import 'package:chatify_app/pages/recent_conversations_page.dart';
import 'package:chatify_app/pages/search_page.dart';
//import 'package:chatify_app/providers/auth_provider.dart';
//import 'package:chatify_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // AuthProvider? _auth;
  TabController? _tabController;
  double? _height, _width;

  // _HomePageState(){
  //   _tabController = TabController(length: 1, vsync: this, initialIndex: 0);
  // }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatify',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          //indicatorColor: Colors.blue,
          //labelColor: Colors.blue,
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.people_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      body:  _tabBarPage(),
    );
  }

  Widget _tabBarPage(){
    return TabBarView(controller: _tabController ,children: <Widget>[
      SearchPage(_height!, _width!),
      RecentConversationsPage(_height!, _width!),
      ProfilePage(_height!, _width!),
    ]);
  }
  
}
