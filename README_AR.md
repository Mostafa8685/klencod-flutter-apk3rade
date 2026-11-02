# apk3rade — Flutter WebView App

تطبيق Android لمتجر https://apk3rade.mangoad.online/ بواجهة خضراء.

## البناء
1. فك ضغط المشروع.
2. افتح مجلد المشروع باستخدام Android Studio أو VS Code مع Flutter.
3. نفّذ:
   flutter pub get
   flutter build apk --release
4. ملف APK الناتج يوجد في:
   build/app/outputs/flutter-apk/app-release.apk

## ملاحظات
- يحتاج الجهاز إلى اتصال بالإنترنت.
- زر الرجوع يتنقل داخل صفحات الموقع أولاً، ثم يتطلب ضغطتين للخروج.
- روابط المواقع الخارجية تفتح في المتصفح أو التطبيق المناسب.
- غيّر رابط المتجر من المتغير `homeUrl` في `lib/main.dart` إذا احتجت ذلك.
