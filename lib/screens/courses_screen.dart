import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/pool_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override State<CoursesScreen> createState() => _CoursesScreenState();
}
class _CoursesScreenState extends State<CoursesScreen> {
  final _service = PoolService(); List<CourseItem> _items = []; bool _loading = true;
  @override void initState() { super.initState(); _load(); activeCitizenId.addListener(_load); }
  @override void dispose() { activeCitizenId.removeListener(_load); super.dispose(); }
  Future<void> _load() async { final items = await _service.fetchCourses(); if (mounted) setState(() { _items = items; _loading = false; }); }
  @override Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('Tanımlı kurs kaydınız bulunmuyor.'));
    final df = DateFormat('d MMM yyyy', 'tr_TR');
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: _items.map((c) => Card(
      margin: const EdgeInsets.only(bottom: 14), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.courseName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(c.facilityName, style: const TextStyle(color: Color(0xFF0F4C81))),
        if (c.instructorName != null) Text('Eğitmen: ${c.instructorName}'), const Divider(),
        Text('${df.format(c.startsOn)} – ${df.format(c.endsOn)}'),
        if (c.extendedDays > 0) Text('${c.extendedDays} gün telafi/rapor uzatması', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...c.schedules.map((s) => Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.schedule, size: 17), const SizedBox(width: 7), Text('${s.day}  ${s.startsAt.substring(0, 5)}–${s.endsAt.substring(0, 5)}')]))),
      ]))),
    ).toList(),));
  }
}
