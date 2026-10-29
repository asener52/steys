import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key});

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {
  final _service = PoolService();
  List<MembershipItem> _items = [];
  bool _loading = true;

  static const _statusLabel = {0: 'Aktif', 1: 'Süresi Dolmuş', 2: 'İptal', 3: 'Askıda'};

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
    final citizenId = await _service.effectiveCitizenId;
    if (citizenId == null) {
      setState(() => _loading = false);
      return;
    }
    final items = await _service.fetchMyMemberships(citizenId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final dateFormat = DateFormat('d MMM yyyy', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _load,
      child: _items.isEmpty
          ? ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Text('Üyeliğiniz bulunmuyor.'))])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = _items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.packageName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(_statusLabel[m.status] ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${dateFormat.format(m.startDate.toLocal())} - ${dateFormat.format(m.endDate.toLocal())}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('Kalan Hak: ${m.availableRights?.toString() ?? "Sınırsız"}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
