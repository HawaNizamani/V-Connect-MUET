import 'package:flutter/material.dart';
import 'custom_bottom_navbar.dart';
import 'opportunity_detail_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';

class AvailableOpportunitiesScreen extends StatefulWidget {
  const AvailableOpportunitiesScreen({super.key});

  @override
  State<AvailableOpportunitiesScreen> createState() =>
      _AvailableOpportunitiesScreenState();
}

class _AvailableOpportunitiesScreenState extends State<AvailableOpportunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> favorites = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void toggleFavorite(int index) {
    setState(() {
      if (favorites.contains(index)) {
        favorites.remove(index);
      } else {
        favorites.add(index);
      }
    });
  }

  void _onNavTap(int index) {
    if (index == 1) return; // Already on this screen

    switch (index) {
      case 0:
      // Replace dummy info with actual user data if needed
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1D56);
    const Color backgroundColor = Color(0xFFF5F9FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Available Opportunities',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
            splashRadius: 24,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
            splashRadius: 24,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'In MUET'),
            Tab(text: 'Near Me'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildOpportunityList(),
          buildOpportunityList(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }

  Widget buildOpportunityList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OpportunityDetailScreen()),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/wall_of_hope.png'),
                        radius: 25,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Be the Change',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('How youth can thrive in Social Movements'),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text('Software department MUET',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          favorites.contains(index) ? Icons.favorite : Icons.favorite_border,
                          color: favorites.contains(index) ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => toggleFavorite(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Chip(
                        label: Text("One-day Event"),
                        backgroundColor: Color(0xFFEDEDED),
                      ),
                      SizedBox(width: 6),
                      Chip(
                        label: Text("Community +1 more"),
                        backgroundColor: Color(0xFFEDEDED),
                      ),
                      Spacer(),
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('4 hours ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}