import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final _service = PoolService();
  List<SessionOccurrence> _sessions = [];
  bool _loading = true;
  String? _bookingMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _service.fetchSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _book(SessionOccurrence s) async {
    final error = await _service.bookReservation(s.id);
    if (!mounted) return;
    setState(() => _bookingMessage = error ?? 'Rezervasyon oluşturuldu: ${s.templateName}');
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_bookingMessage!)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final dateFormat = DateFormat('d MMM, HH:mm', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _load,
      child: _sessions.isEmpty
          ? ListView(children: const [Padding(padding: EdgeInsets.all(32), child: Text('Yaklaşan seans bulunamadı.'))])
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = _sessions[index];
                final isFull = s.remaining <= 0;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.templateName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(dateFormat.format(s.startsAt.toLocal()), style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              'Kapasite: ${s.capacity}  ·  Dolu: ${s.booked}  ·  Kalan: ${s.remaining}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isFull ? null : () => _book(s),
                        child: Text(isFull ? 'Dolu' : 'Rezerve Et'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
