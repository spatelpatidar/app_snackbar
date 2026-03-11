// full demo (all features)
import 'package:app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 1. Messenger key define karo (Queue support ke liye zaroori hai)
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  // 2. Entrypoint function yahan hona chahiye
  WidgetsFlutterBinding.ensureInitialized();

  // AppSnackBar setup
  AppSnackBar.messengerKey = rootMessengerKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootMessengerKey, // 3. Key yahan attach karo
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const ShowcaseScreen(), // 4. Aapka naya screen
    );
  }
}

/// 🎨 Showcase Screen — for screenshots & demo
/// Replace your main.dart home with this screen
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _Header(),
              const SizedBox(height: 32),

              // ── Types ──────────────────────────────────────────────────────
              const _SectionLabel('SNACKBAR TYPES'),
              const SizedBox(height: 12),
              _TypesGrid(),
              const SizedBox(height: 28),

              // ── Positions ──────────────────────────────────────────────────
              const _SectionLabel('POSITION'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PillBtn(
                      label: '⬇️  Bottom',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.info(
                          context, 'Showing at bottom!'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillBtn(
                      label: '⬆️  Top',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.info(
                        context,
                        'Showing at top!',
                        position: SnackBarPosition.top,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Animations ────────────────────────────────────────────────
              const _SectionLabel('ANIMATION'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PillBtn(
                      label: '🎞  Slide',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.info(
                        context,
                        'Slide animation!',
                        animation: SnackBarAnimation.slide,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PillBtn(
                      label: '✨  Fade',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.info(
                        context,
                        'Fade animation!',
                        animation: SnackBarAnimation.fade,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PillBtn(
                      label: '⚡  None',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.info(
                        context,
                        'No animation.',
                        animation: SnackBarAnimation.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Action & Loading ──────────────────────────────────────────
              const _SectionLabel('ACTION & LOADING'),
              const SizedBox(height: 12),
              _ActionCard(context: context),
              const SizedBox(height: 28),

              // ── Queue ─────────────────────────────────────────────────────
              const _SectionLabel('QUEUE MODE'),
              const SizedBox(height: 12),
              _QueueCard(context: context),
              const SizedBox(height: 28),

              // ── Custom Code ───────────────────────────────────────────────
              const _SectionLabel('✏️  CUSTOM CODE'),
              const SizedBox(height: 12),
              _CustomCodeCard(context: context),
              const SizedBox(height: 12),
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
              Row(
                children: [
                  Expanded(
                    child: _PillBtn(
                      label: '👤 Custom Leading (Avatar)',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.show(
                        context, 'New message from Dev!',
                        type: SnackBarType.info,
                        leading: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white30,
                          child: Text('A',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillBtn(
                      label: '🔘 Custom Trailing Button',
                      color: const Color(0xFF1E2640),
                      onTap: () => AppSnackBar.show(
                        context,
                        'File ready to open.',
                        type: SnackBarType.success,
                        showClose: false,
                        trailing: TextButton(
                          onPressed: () => AppSnackBar.hide(context),
                          child:
                          const Text('Open', style: TextStyle(color: Colors.white)),
                        ),                      ),
                    ),
                  ),
                ],
              ),

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
        ),
      ),
    );
  }
}

// ── Header Widget ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.5)),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  color: Color(0xFF66BB6A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF003249).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF003249).withValues(alpha: 0.6)),
              ),
              child: const Text(
                'Flutter 3.16+',
                style: TextStyle(
                  color: Color(0xFF81D4FA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'app_snackbar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Beautiful, customizable Flutter SnackBars.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ── Types Grid ────────────────────────────────────────────────────────────────

class _TypesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final types = [
      _TypeItem('Success', '✅', const Color(0xFF2E7D32), const Color(0xFF1B5E20),
              () => AppSnackBar.success(context, 'Profile updated successfully!',backgroundColor: Colors.transparent, borderColor: Colors.white30, borderWidth: 1.5,duration: const Duration(seconds: 3))),
      _TypeItem('Error', '❌', const Color(0xFFC62828), const Color(0xFF7F0000),
              () => AppSnackBar.error(context, 'Upload failed. Try again.',borderColor: Colors.purple,
            borderWidth: 1.5,)),
      _TypeItem('Warning', '⚠️', const Color(0xFFE65100), const Color(0xFFBF360C),
              () => AppSnackBar.warning(context, 'Download cancelled.', position: SnackBarPosition.bottom)),
      _TypeItem('Info', 'ℹ️', const Color(0xFF003249), const Color(0xFF001F2E),
              () => AppSnackBar.info(context, 'New version available.')),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: types
          .map((t) => _TypeCard(
        label: t.label,
        emoji: t.emoji,
        color: t.color,
        darkColor: t.darkColor,
        onTap: t.onTap,
      ))
          .toList(),
    );
  }
}

class _TypeItem {
  final String label, emoji;
  final Color color, darkColor;
  final VoidCallback onTap;
  const _TypeItem(
      this.label, this.emoji, this.color, this.darkColor, this.onTap);
}

class _TypeCard extends StatelessWidget {
  final String label, emoji;
  final Color color, darkColor;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.emoji,
    required this.color,
    required this.darkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.25), darkColor.withValues(alpha: 0.15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action & Loading Card ─────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final BuildContext context;
  const _ActionCard({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141928),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DarkBtn(
                  label: '↩️  Undo',
                  accent: const Color(0xFFE65100),
                  onTap: () => AppSnackBar.showWithAction(
                    context,
                    'Message deleted.',
                    actionLabel: 'Undo',
                    type: SnackBarType.warning,
                    onAction: () =>
                        AppSnackBar.success(context, 'Message restored!'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DarkBtn(
                  label: '🔄  Retry',
                  accent: const Color(0xFFC62828),
                  onTap: () => AppSnackBar.showWithAction(
                    context,
                    'Upload failed.',
                    actionLabel: 'Retry',
                    type: SnackBarType.error,
                    onAction: () =>
                        AppSnackBar.info(context, 'Retrying...'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DarkBtn(
            label: '⏳  Loading → Success',
            accent: const Color(0xFF003249),
            fullWidth: true,
            onTap: () async {
              AppSnackBar.showLoading(context, 'Uploading photo...');
              await Future.delayed(const Duration(seconds: 2));
              if (!context.mounted) return; // ✅ guard before using context after await
              AppSnackBar.success(context, 'Upload complete! ✅');
              // AppSnackBar.showLoading(context, 'Uploading photo...');
              // Future.delayed(
              //   const Duration(seconds: 2),
              //       () => AppSnackBar.success(context, 'Upload complete! ✅'),
              // );
            },
          ),
        ],
      ),
    );
  }
}

// ── Queue Card ────────────────────────────────────────────────────────────────

class _QueueCard extends StatelessWidget {
  final BuildContext context;
  const _QueueCard({required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141928),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _DarkBtn(
              label: '📋  Queue 3 Snackbars',
              accent: const Color(0xFF2E7D32),
              onTap: () {
                AppSnackBar.useQueue = true;
                AppSnackBar.success(null, 'Step 1: Data saved ✅');
                AppSnackBar.info(null, 'Step 2: Syncing...');
                AppSnackBar.success(null, 'Step 3: All done! 🎉');
                Future.delayed(
                    const Duration(seconds: 10),
                        () => AppSnackBar.useQueue = false);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DarkBtn(
              label: '🗑️  Clear',
              accent: const Color(0xFFC62828),
              onTap: () {
                AppSnackBar.clearQueue();
                AppSnackBar.warning(context, 'Queue cleared.');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Code Card ──────────────────────────────────────────────────────────

class _CustomCodeCard extends StatefulWidget {
  final BuildContext context;
  const _CustomCodeCard({required this.context});

  @override
  State<_CustomCodeCard> createState() => _CustomCodeCardState();
}

class _CustomCodeCardState extends State<_CustomCodeCard> {
  // ── Options state ──────────────────────────────────────────────────────────
  SnackBarType _type = SnackBarType.success;
  SnackBarPosition _position = SnackBarPosition.bottom;
  SnackBarAnimation _animation = SnackBarAnimation.slide;
  int _duration = 3;
  double _borderRadius = 16;
  double _fontSize = 14;
  double _elevation = 6;
  bool _showClose = true;
  bool _showTimer = false;
  Color? _customBg;

  String _message = "Hello World! 👋";
  final _messageController = TextEditingController(text: "Hello World! 👋");

  // ── Generated code ─────────────────────────────────────────────────────────
  String get _generatedCode {
    final lines = <String>[
      'AppSnackBar.show(',
      '  context,',
      "  '$_message',",
      if (_type != SnackBarType.info) '  type: SnackBarType.${_type.name},',
      if (_position != SnackBarPosition.bottom) '  position: SnackBarPosition.top,',
      if (_animation != SnackBarAnimation.slide) '  animation: SnackBarAnimation.${_animation.name},',
      if (_duration != 3) '  duration: const Duration(seconds: $_duration),',
      if (_borderRadius != 16) '  borderRadius: $_borderRadius,',
      if (_fontSize != 14) '  fontSize: $_fontSize,',
      if (_elevation != 6) '  elevation: $_elevation,',
      if (_customBg != null)
        '  backgroundColor: const Color(0xFF${_customBg!.toARGB32().toRadixString(16).substring(2).toUpperCase()}),',
      if (!_showClose) '  showClose: false,',
      if (_showTimer) '  showTimer: true,',
      ');',
    ];
    return lines.join('\n');
  }

  // ── Run preview ────────────────────────────────────────────────────────────
  void _run() {
    HapticFeedback.mediumImpact();
    AppSnackBar.show(
      widget.context,
      _message,
      type: _type,
      position: _position,
      animation: _animation,
      duration: Duration(seconds: _duration),
      borderRadius: _borderRadius,
      fontSize: _fontSize,
      elevation: _elevation,
      backgroundColor: _customBg,
      showClose: _showClose,
      showTimer: _showTimer,
    );
  }

  // ── Copy code ──────────────────────────────────────────────────────────────
  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    AppSnackBar.success(
      widget.context,
      'Code copied!',
      duration: const Duration(seconds: 3),
      animation: SnackBarAnimation.slide,
      showTimer: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontFamily: 'monospace',
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _segmented<T>({
    required List<T> values,
    required List<String> labels,
    required T selected,
    required void Function(T) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(values.length, (i) {
          final isSelected = values[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => onChanged(values[i])),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required void Function(double) onChanged,
    String unit = '',
    int divisions = 0,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Color(0xFF58A6FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: Colors.white10,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions > 0 ? divisions : null,
              onChanged: (v) => setState(() => onChanged(v)),
            ),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}$unit',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF58A6FF),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleRow(String label, bool value, void Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace')),
        Switch(
          value: value,
          onChanged: (v) => setState(() => onChanged(v)),
          activeThumbColor: const Color(0xFF58A6FF),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const _Dot(Color(0xFFFF5F56)),
                const SizedBox(width: 6),
                const _Dot(Color(0xFFFFBD2E)),
                const SizedBox(width: 6),
                const _Dot(Color(0xFF27C93F)),
                const Spacer(),
                Text(
                  'playground.dart',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Message ───────────────────────────────────────────────
                _sectionLabel('MESSAGE'),
                TextField(
                  controller: _messageController,
                  onChanged: (v) => setState(() => _message = v),
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  cursorColor: const Color(0xFF58A6FF),
                ),

                _divider(),

                // ── Type ──────────────────────────────────────────────────
                _sectionLabel('TYPE'),
                _segmented(
                  values: SnackBarType.values,
                  labels: ['✓ success', '✕ error', '⚠ warning', 'ℹ info'],
                  selected: _type,
                  onChanged: (v) => _type = v,
                ),

                _divider(),

                // ── Position ──────────────────────────────────────────────
                _sectionLabel('POSITION'),
                _segmented(
                  values: SnackBarPosition.values,
                  labels: ['⬇ bottom', '⬆ top'],
                  selected: _position,
                  onChanged: (v) => _position = v,
                ),

                _divider(),

                // ── Animation ─────────────────────────────────────────────
                _sectionLabel('ANIMATION'),
                _segmented(
                  values: SnackBarAnimation.values,
                  labels: ['slide', 'fade', 'none'],
                  selected: _animation,
                  onChanged: (v) => _animation = v,
                ),

                _divider(),

                // ── Duration ──────────────────────────────────────────────
                _sectionLabel('DURATION'),
                _sliderRow(
                  label: '${_duration}s',
                  value: _duration.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  unit: 's',
                  onChanged: (v) => _duration = v.round(),
                ),

                _divider(),

                // ── Shape ─────────────────────────────────────────────────
                _sectionLabel('SHAPE & SIZE'),
                _sliderRow(
                  label: 'radius',
                  value: _borderRadius,
                  min: 0,
                  max: 28,
                  divisions: 28,
                  unit: 'px',
                  onChanged: (v) => _borderRadius = v,
                ),
                const SizedBox(height: 8),
                _sliderRow(
                  label: 'elevation',
                  value: _elevation,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  onChanged: (v) => _elevation = v,
                ),

                _divider(),

                // ── Font size ─────────────────────────────────────────────
                _sectionLabel('FONT SIZE'),
                _sliderRow(
                  label: 'size',
                  value: _fontSize,
                  min: 10,
                  max: 22,
                  divisions: 12,
                  unit: 'px',
                  onChanged: (v) => _fontSize = v,
                ),

                _divider(),

                // ── Background Color ──────────────────────────────────────
                _sectionLabel('BACKGROUND COLOR'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Default (auto) dot
                    GestureDetector(
                      onTap: () => setState(() => _customBg = null),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _customBg == null ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: _customBg == null
                              ? [const BoxShadow(color: Colors.white30, blurRadius: 4)]
                              : null,
                        ),
                        child: _customBg == null
                            ? const Icon(Icons.auto_awesome, color: Colors.white, size: 14)
                            : null,
                      ),
                    ),
                    // Preset colors
                    for (final color in [
                      const Color(0xFF2E7D32),
                      const Color(0xFFC62828),
                      const Color(0xFFE65100),
                      const Color(0xFF003249),
                      const Color(0xFF6A0DAD),
                      const Color(0xFF0277BD),
                      const Color(0xFF00838F),
                      const Color(0xFFAD1457),
                      const Color(0xFF37474F),
                    ])
                      GestureDetector(
                        onTap: () => setState(() => _customBg = color),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _customBg == color ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: _customBg == color
                                ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)]
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // Hex input row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final hexController = TextEditingController(
                          text: _customBg != null
                              ? _customBg!.toARGB32().toRadixString(16).substring(2).toUpperCase()
                              : '',
                        );
                        await showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF161B22),
                            title: const Text(
                              'Enter Hex Color',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            content: TextField(
                              controller: hexController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                hintText: 'e.g. FF5733',
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixText: '# ',
                                prefixStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white10,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              cursorColor: const Color(0xFF58A6FF),
                              maxLength: 6,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () {
                                  final hex = hexController.text.trim();
                                  if (hex.length == 6) {
                                    final parsed = int.tryParse('FF$hex', radix: 16);
                                    if (parsed != null) setState(() => _customBg = Color(parsed));
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Apply', style: TextStyle(color: Color(0xFF58A6FF))),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _customBg ?? const Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _customBg != null
                                  ? '#${_customBg!.toARGB32().toRadixString(16).substring(2).toUpperCase()}'
                                  : '# custom hex',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_customBg != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _customBg = null),
                        child: const Text(
                          '✕ reset',
                          style: TextStyle(color: Colors.white30, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ],
                ),

                _divider(),

                // ── Toggles ───────────────────────────────────────────────
                _sectionLabel('OPTIONS'),
                _toggleRow('showClose', _showClose, (v) => _showClose = v),
                _toggleRow('showTimer', _showTimer, (v) => _showTimer = v),

                _divider(),

                // ── Generated code ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('GENERATED CODE'),
                    GestureDetector(
                      onTap: _copyCode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          '⎘ copy',
                          style: TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Text(
                    _generatedCode,
                    style: const TextStyle(
                      color: Color(0xFFA5D6FF),
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Run button ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _run,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text(
                  'Run Preview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PillBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DarkBtn extends StatelessWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool fullWidth;

  const _DarkBtn({
    required this.label,
    required this.accent,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
