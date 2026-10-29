import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _service = PoolService();
  List<ReservationItem> _items = [];
  bool _loading = true;

  static const _statusLabel = {0: 'Rezerve', 1: 'İptal Edildi', 2: 'Check-in Yapıldı', 3: 'Gelinmedi'};

  @override
  void initState() {
    super.initState();
    _load();
    activeCitizenId.addListener(_load);
  }

  @override
  void dispose() {
    activeCitizenId.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final citizenId = await _service.effectiveCitizenId;
    if (citizenId == null) {
      setState(() => _loading = false);
      return;
    }
    final items = await _service.fetchMyReservations(citizenId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _load,
      child: _items.isEmpty
          ? ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Text('Rezervasyonunuz bulunmuyor.'))])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = _items[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(r.createdAt.toLocal())),
                      Text(_statusLabel[r.status] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
