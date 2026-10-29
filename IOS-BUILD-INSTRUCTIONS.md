# App Store Connect derleme adımı

Bu kaynak Windows üzerinde hazırlandı. Apple imzası ve IPA yalnızca macOS/Xcode ile üretilebilir.

1. `flutter pub get` çalıştırın.
2. `ios/Runner.xcworkspace` dosyasını Xcode ile açın.
3. Runner > Signing & Capabilities bölümünde belediyenin Apple Developer Team hesabını seçin.
4. Bundle ID değerini `tr.bel.unye.steys` olarak doğrulayın.
5. Product > Archive çalıştırın.
6. Distribute App > App Store Connect > Upload yolunu izleyin.

Komut satırı alternatifi:

```sh
flutter build ipa --release --build-name=1.1.0 --build-number=4 --export-options-plist=ios/ExportOptions.plist
```

Sürüm: 1.1.0 (build 4)
Kamera açıklaması ve App Store export seçenekleri projeye eklenmiştir.
