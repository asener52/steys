import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/pool_service.dart';
import 'announcements_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'memberships_screen.dart';
import 'profile_screen.dart';
import 'qr_screen.dart';
import 'reservations_screen.dart';
import 'sessions_screen.dart';
import 'courses_screen.dart';

const _titles = [
  'Ana Sayfa',
  'QR ile Giriş',
  'Seanslar',
  'Rezervasyonlarım',
  'Giriş Geçmişim',
  'Üyeliklerim',
  'Duyurular',
  'Profil',
  'Kurslarım',
];

const _screens = [
  HomeScreen(),
  QrScreen(),
  SessionsScreen(),
  ReservationsScreen(),
  HistoryScreen(),
  MembershipsScreen(),
  AnnouncementsScreen(),
  ProfileScreen(),
  CoursesScreen(),
];

const _drawerIcons = [
  Icons.home,
  Icons.qr_code_2,
  Icons.pool,
  Icons.event_available,
  Icons.history,
  Icons.card_membership,
  Icons.campaign,
  Icons.person,
  Icons.school,
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

// Maps the 4 primary bottom-nav slots to their real screen index in _screens/_titles.
const _bottomNavScreenIndices = [0, 1, 2, 7]; // Ana Sayfa, Giriş, Seanslar, Profil

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _service = PoolService();
  List<FamilyMember> _family = [];

  @override
  void initState() {
    super.initState();
    _service.fetchFamily().then((members) {
      if (mounted) setState(() => _family = members);
    });
  }

  void _selectProfile(FamilyMember member) {
    activeCitizenId.value = member.isSelf ? null : member.citizenId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(_titles[_index]),
        backgroundColor: const Color(0xFF0F4C81),
        foregroundColor: Colors.white,
        actions: _family.length > 1
            ? [
                ValueListenableBuilder<String?>(
                  valueListenable: activeCitizenId,
                  builder: (context, selectedId, _) {
                    final active = _family.firstWhere(
                      (m) => selectedId == null ? m.isSelf : m.citizenId == selectedId,
                      orElse: () => _family.first,
                    );
                    return PopupMenuButton<FamilyMember>(
                      onSelected: _selectProfile,
                      itemBuilder: (context) => _family
                          .map((m) => PopupMenuItem(
                                value: m,
                                child: Row(
                                  children: [
                                    if ((selectedId == null && m.isSelf) || selectedId == m.citizenId)
                                      const Icon(Icons.check, size: 18, color: Color(0xFF0F4C81))
                                    else
                                      const SizedBox(width: 18),
                                    const SizedBox(width: 8),
                                    Text('${m.firstName} ${m.lastName}'),
                                  ],
                                ),
                              ))
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.switch_account, size: 20),
                            const SizedBox(width: 6),
                            Text(active.firstName, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0F4C81)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Ünye Belediyesi\nSpor Tesisleri',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            for (var i = 0; i < _titles.length; i++)
              ListTile(
                leading: Icon(_drawerIcons[i]),
                title: Text(_titles[i]),
                selected: i == _index,
                onTap: () {
                  setState(() => _index = i);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomNavScreenIndices.contains(_index) ? _bottomNavScreenIndices.indexOf(_index) : 0,
        onDestinationSelected: (i) => setState(() => _index = _bottomNavScreenIndices[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'QR Oku'),
          NavigationDestination(icon: Icon(Icons.pool), label: 'Seanslar'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
