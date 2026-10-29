import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/pool_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final _privacyUri = Uri.parse('https://steys.unye.bel.tr/gizlilik-politikasi');
  final _service = PoolService();
  HomeSummary? _summary;
  bool _exporting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _service.fetchHome().then((s) {
      if (mounted) setState(() => _summary = s);
    });
  }

  Future<void> _logout() async {
    await _service.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    final json = await _service.exportMyData();
    if (!mounted) return;
    setState(() => _exporting = false);
    if (json == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veriler alınamadı.')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verilerim'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(json, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Panoya kopyalandı.')));
            },
            child: const Text('Kopyala'),
          ),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Kapat')),
        ],
      ),
    );
  }

  Future<void> _requestDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabımı Sil'),
        content: const Text(
          'KVKK kapsamında kişisel verilerinizin silinmesini talep edeceksiniz. Talebiniz yetkili ekip tarafından incelenip işleme alınacaktır. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Evet, talep oluştur')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    final message = await _service.requestAccountDeletion();
    if (!mounted) return;
    setState(() => _deleting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Talep gönderilemedi, lütfen tekrar deneyin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: const Color(0xFF0F4C81),
          child: Text(
            _summary != null ? '${_summary!.firstName[0]}${_summary!.lastName[0]}' : '',
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _summary != null ? '${_summary!.firstName} ${_summary!.lastName}' : '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _exporting ? null : _exportData,
          icon: _exporting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_outlined),
          label: const Text('Verilerimi Dışa Aktar'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Çıkış Yap'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: () => launchUrl(_privacyUri, mode: LaunchMode.externalApplication), icon: const Icon(Icons.privacy_tip_outlined), label: const Text('Gizlilik Politikası')),
        TextButton.icon(
          onPressed: _deleting ? null : _requestDeletion,
          icon: _deleting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.delete_forever_outlined, color: Colors.red),
          label: const Text('Hesabımı Sil (KVKK)', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
