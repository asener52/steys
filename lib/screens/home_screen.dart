import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = PoolService();
  HomeSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    accessRefreshTick.addListener(_load);
    activeCitizenId.addListener(_load);
  }

  @override
  void dispose() {
    accessRefreshTick.removeListener(_load);
    activeCitizenId.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final summary = await _service.fetchHome();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_summary == null) {
      return const Center(child: Text('Veriler yüklenemedi.'));
    }

    final s = _summary!;
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Merhaba ${s.firstName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (s.memberships.isEmpty)
            const _InfoCard(title: 'Üyelik', value: 'Aktif üyeliğiniz bulunmuyor')
          else
            for (final m in s.memberships) ...[
              _MembershipCard(membership: m, dateFormat: dateFormat),
              const SizedBox(height: 12),
            ],
          if (s.lastAccessAt != null)
            _InfoCard(title: 'Son Kullanım', value: dateFormat.format(s.lastAccessAt!.toLocal())),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final HomeMembershipSummary membership;
  final DateFormat dateFormat;

  const _MembershipCard({required this.membership, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(membership.facilityName, style: const TextStyle(color: Color(0xFF0F4C81), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(membership.packageName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kalan Hak', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    membership.remainingRights?.toString() ?? 'Sınırsız',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Üyelik Bitiş', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(dateFormat.format(membership.endDate.toLocal()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
