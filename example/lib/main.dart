// full demo (all features)
import 'package:app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';

/// Register root messenger key — required for queue + above bottom sheet.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  // 1. Set the global messenger key
  AppSnackBar.messengerKey = rootMessengerKey;

  // 2. Set global theme — override colors, fonts, animation, etc.
  AppSnackBar.theme = const AppSnackBarTheme(
    infoColor: Color(0xFF003249),
    borderRadius: 16,
    elevation: 6,
    fontSize: 14,
    defaultAnimation: SnackBarAnimation.slide,
    animationDuration: Duration(milliseconds: 300),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppSnackBar Demo',
      scaffoldMessengerKey: rootMessengerKey,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppSnackBar Demo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Basic types ─────────────────────────────────────────────────
          _SectionTitle('Basic Types'),
          _Btn('✅ Success', const Color(0xFF2E7D32), () =>
              AppSnackBar.success(context, 'Profile updated successfully!')),
          _Btn('❌ Error', const Color(0xFFC62828), () =>
              AppSnackBar.error(context, 'Upload failed. Try again.')),
          _Btn('⚠️ Warning', const Color(0xFFE65100), () =>
              AppSnackBar.warning(context, 'Download cancelled.')),
          _Btn('ℹ️ Info', const Color(0xFF003249), () =>
              AppSnackBar.info(context, 'New version available.')),

          // ── Position ────────────────────────────────────────────────────
          _SectionTitle('Position'),
          _Btn('⬇️ Bottom (default)', null, () =>
              AppSnackBar.success(context, 'Showing at bottom!')),
          _Btn('⬆️ Top', null, () =>
              AppSnackBar.success(context, 'Showing at top!',
                  position: SnackBarPosition.top)),

          // ── Animation ───────────────────────────────────────────────────
          _SectionTitle('Animation'),
          _Btn('🎞️ Slide (default)', null, () =>
              AppSnackBar.info(context, 'Slide animation!',
                  animation: SnackBarAnimation.slide)),
          _Btn('✨ Fade', null, () =>
              AppSnackBar.info(context, 'Fade animation!',
                  animation: SnackBarAnimation.fade)),
          _Btn('⚡ None', null, () =>
              AppSnackBar.info(context, 'No animation.',
                  animation: SnackBarAnimation.none)),

          // ── Action button ───────────────────────────────────────────────
          _SectionTitle('With Action Button'),
          _Btn('↩️ Undo Action', null, () =>
              AppSnackBar.showWithAction(
                context,
                'Message deleted.',
                actionLabel: 'Undo',
                type: SnackBarType.warning,
                onAction: () =>
                    AppSnackBar.success(context, 'Message restored!'),
              )),
          _Btn('🔄 Retry Action', null, () =>
              AppSnackBar.showWithAction(
                context,
                'Upload failed.',
                actionLabel: 'Retry',
                type: SnackBarType.error,
                onAction: () =>
                    AppSnackBar.info(context, 'Retrying upload...'),
              )),

          // ── Loading ─────────────────────────────────────────────────────
          _SectionTitle('Loading'),
          _Btn('⏳ Loading → Success', null, () {
            AppSnackBar.showLoading(context, 'Uploading photo...');
            Future.delayed(const Duration(seconds: 2),
                    () => AppSnackBar.success(context, 'Upload complete! ✅'));
          }),

          // ── Queue ───────────────────────────────────────────────────────
          _SectionTitle('Queue Mode'),
          _Btn('📋 Queue 3 Snackbars', null, () {
            AppSnackBar.useQueue = true;
            AppSnackBar.success(null, 'Step 1: Data saved ✅');
            AppSnackBar.info(null, 'Step 2: Syncing to cloud...');
            AppSnackBar.success(null, 'Step 3: All done! 🎉');
            // Reset after demo
            Future.delayed(
                const Duration(seconds: 10),
                    () => AppSnackBar.useQueue = false);
          }),
          _Btn('🗑️ Clear Queue', null, () {
            AppSnackBar.clearQueue();
            AppSnackBar.warning(context, 'Queue cleared.');
          }),

          // ── Custom styling ──────────────────────────────────────────────
          const _SectionTitle('Custom Styling'),
          _Btn('🎨 Custom Background Color', null, () =>
              AppSnackBar.show(context, 'Custom purple!',
                  backgroundColor: Colors.deepPurple)),
          _Btn('🔤 Custom Font Size', null, () =>
              AppSnackBar.info(context, 'Big text!', fontSize: 18)),
          _Btn('💪 Custom Bold TextStyle', null, () =>
              AppSnackBar.success(
                context,
                'Bold italic text!',
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              )),
          _Btn('📐 Custom Border Radius', null, () =>
              AppSnackBar.show(context, 'Sharp corners!', borderRadius: 4)),
          _Btn('🌫️ Custom Elevation', null, () =>
              AppSnackBar.show(context, 'High shadow!', elevation: 16)),

          // ── Custom widgets ──────────────────────────────────────────────
          const _SectionTitle('Custom Widgets'),
          _Btn('👤 Custom Leading (Avatar)', null, () =>
              AppSnackBar.show(
                context,
                'New message from Ali',
                type: SnackBarType.info,
                leading: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white30,
                  child: Text('A',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              )),
          _Btn('🔘 Custom Trailing Button', null, () =>
              AppSnackBar.show(
                context,
                'File ready to open.',
                type: SnackBarType.success,
                showClose: false,
                trailing: TextButton(
                  onPressed: () => AppSnackBar.hide(context),
                  child:
                  const Text('Open', style: TextStyle(color: Colors.white)),
                ),
              )),

          // ── Bottom sheet demo ───────────────────────────────────────────
          const _SectionTitle('Above Bottom Sheet'),
          _Btn('📋 Open Bottom Sheet', null, () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('I am a bottom sheet!',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      // null context → uses messengerKey → shows ABOVE sheet ✅
                      onPressed: () =>
                          AppSnackBar.success(null, 'Visible above sheet! ✅'),
                      child: const Text('Show Snackbar Above Sheet'),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _Btn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: color != null ? Colors.white : null,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onTap,
          child: Text(label),
        ),
      ),
    );
  }
}
