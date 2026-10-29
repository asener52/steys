import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/pool_service.dart';

class QrScreen extends StatefulWidget { const QrScreen({super.key}); @override State<QrScreen> createState() => _QrScreenState(); }
class _QrScreenState extends State<QrScreen> {
  final _service = PoolService(); final _controller = MobileScannerController(); bool _processing = false; String? _message; bool? _approved;
  Future<void> _scan(BarcodeCapture capture) async {
    if (_processing) return; final raw = capture.barcodes.firstOrNull?.rawValue; if (raw == null) return;
    setState(() => _processing = true); await _controller.stop(); final result = await _service.redeemKioskQr(raw);
    if (!mounted) return; setState(() { _approved = result['approved'] == true; _message = result['message']?.toString() ?? (_approved! ? 'Giriş onaylandı.' : 'Giriş reddedildi.'); });
  }
  Future<void> _again() async {
    setState(() { _processing = false; _message = null; _approved = null; });
    await _controller.start();
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    const Text('Kiosk ekranındaki geçici QR kodunu okutun', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Stack(fit: StackFit.expand, children: [
      MobileScanner(controller: _controller, onDetect: _scan),
      if (_message != null) Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(_approved! ? Icons.check_circle : Icons.cancel, size: 90, color: _approved! ? Colors.green : Colors.red),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(_message!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _again, icon: const Icon(Icons.qr_code_scanner), label: const Text('Yeni QR Okut')),
        ])),
      ),
    ]))),
    const SizedBox(height: 12), const Text('Kod 30 saniye geçerlidir ve yalnızca bir kez kullanılabilir.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
  ]));
}
