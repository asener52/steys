import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = PoolService();
  List<AccessHistoryItem> _items = [];
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
    final items = await _service.fetchAccessHistory();
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
          ? ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Text('Giriş geçmişiniz bulunmuyor.'))])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = _items[index];
                final approved = e.result == 'Approved';
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: Icon(approved ? Icons.check_circle : Icons.cancel, color: approved ? Colors.green : Colors.red),
                  title: Text(dateFormat.format(e.timestamp.toLocal())),
                  subtitle: Text(e.credentialType == 'Rfid' ? 'RFID Kart' : (e.credentialType == 'Qr' ? 'QR Kod' : 'Manuel')),
                  trailing: Text(approved ? 'Başarılı' : 'Reddedildi', style: TextStyle(color: approved ? Colors.green : Colors.red)),
                );
              },
            ),
    );
  }
}
