import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/pool_service.dart';
import 'home_shell.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  static final _privacyUri = Uri.parse('https://steys.unye.bel.tr/gizlilik-politikasi');
  final _service = PoolService(); final _nationalId = TextEditingController(); final _phone = TextEditingController(); final _code = TextEditingController();
  String? _requestId, _maskedPhone, _error; bool _loading = false; int _resendSeconds = 0; Timer? _timer;
  @override void dispose() { _timer?.cancel(); _nationalId.dispose(); _phone.dispose(); _code.dispose(); super.dispose(); }
  void _startTimer() { _timer?.cancel(); setState(() => _resendSeconds = 60); _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (!mounted) return; if (_resendSeconds <= 1) { t.cancel(); setState(() => _resendSeconds = 0); } else { setState(() => _resendSeconds--); } }); }
  Future<void> _requestCode() async {
    if (_nationalId.text.replaceAll(RegExp(r'\D'), '').length != 11) { setState(() => _error = 'T.C. Kimlik No 11 haneli olmalıdır.'); return; }
    if (_phone.text.replaceAll(RegExp(r'\D'), '').length < 10) { setState(() => _error = 'Geçerli bir telefon numarası giriniz.'); return; }
    setState(() { _loading = true; _error = null; }); final result = await _service.requestLoginCode(_nationalId.text, _phone.text);
    if (!mounted) return; setState(() => _loading = false);
    if (!result.success) { setState(() => _error = result.message); return; }
    setState(() { _requestId = result.data!['requestId']; _maskedPhone = result.data!['maskedPhone']; _code.clear(); }); _startTimer();
  }
  Future<void> _verify() async {
    if (_code.text.length != 6) { setState(() => _error = '6 haneli doğrulama kodunu giriniz.'); return; }
    setState(() { _loading = true; _error = null; }); final error = await _service.verifyLoginCode(_requestId!, _code.text);
    if (!mounted) return; setState(() => _loading = false); if (error != null) { setState(() => _error = error); return; }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
  }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFF0F4C81), body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.account_balance, color: Colors.white, size: 62), const SizedBox(height: 12), const Text('Ünye Belediyesi', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), const Text('Tesis Yönetim Sistemi', style: TextStyle(color: Colors.white70)), const SizedBox(height: 28),
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: _requestId == null ? _identityForm() : _codeForm()), const SizedBox(height: 10), TextButton(onPressed: () => launchUrl(_privacyUri, mode: LaunchMode.externalApplication), child: const Text('Gizlilik Politikası', style: TextStyle(color: Colors.white))),
  ])))));
  Widget _identityForm() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Güvenli Giriş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('Kayıtlı telefonunuza tek kullanımlık doğrulama kodu gönderilir.', style: TextStyle(color: Colors.black54)), const SizedBox(height: 18), TextField(controller: _nationalId, keyboardType: TextInputType.number, maxLength: 11, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'T.C. Kimlik No', counterText: '', prefixIcon: Icon(Icons.badge_outlined))), const SizedBox(height: 10), TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon', hintText: '05xx xxx xx xx', prefixIcon: Icon(Icons.phone_outlined))), _errorView(), const SizedBox(height: 16), ElevatedButton(onPressed: _loading ? null : _requestCode, style: _buttonStyle(), child: _buttonChild('SMS Kodu Gönder'))]);
  Widget _codeForm() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Icon(Icons.sms_outlined, size: 44, color: Color(0xFF0F4C81)), const SizedBox(height: 10), const Text('Telefonunuzu Doğrulayın', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('Kod $_maskedPhone numarasına gönderildi.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 18), TextField(controller: _code, autofocus: true, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.bold), inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: '6 haneli kod', counterText: '')), _errorView(), const SizedBox(height: 16), ElevatedButton(onPressed: _loading ? null : _verify, style: _buttonStyle(), child: _buttonChild('Doğrula ve Giriş Yap')), TextButton(onPressed: _loading || _resendSeconds > 0 ? null : _requestCode, child: Text(_resendSeconds > 0 ? 'Yeni kod için $_resendSeconds saniye' : 'Kodu yeniden gönder')), TextButton(onPressed: _loading ? null : () { _timer?.cancel(); setState(() { _requestId = null; _error = null; _resendSeconds = 0; }); }, child: const Text('Bilgileri değiştir'))]);
  Widget _errorView() => _error == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)));
  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C81), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15));
  Widget _buttonChild(String text) => _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(text);
}
