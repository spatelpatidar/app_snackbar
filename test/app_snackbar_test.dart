// 20+ unit & widget tests
import 'package:app_snackbar/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget testApp({GlobalKey<ScaffoldMessengerState>? messengerKey, Widget? body}) {
  return MaterialApp(
    scaffoldMessengerKey: messengerKey,
    home: Scaffold(body: body ?? const SizedBox()),
  );
}

// ── AppSnackBarTheme unit tests ───────────────────────────────────────────────

void main() {
  group('AppSnackBarTheme', () {
    const t = AppSnackBarTheme();

    test('success resolves correct defaults', () {
      final c = t.resolve(SnackBarType.success);
      expect(c.backgroundColor, const Color(0xFF2E7D32));
      expect(c.icon, Icons.check_circle_outline_rounded);
    });

    test('error resolves correct defaults', () {
      final c = t.resolve(SnackBarType.error);
      expect(c.backgroundColor, const Color(0xFFC62828));
      expect(c.icon, Icons.error_outline_rounded);
    });

    test('warning resolves correct defaults', () {
      final c = t.resolve(SnackBarType.warning);
      expect(c.backgroundColor, const Color(0xFFE65100));
      expect(c.icon, Icons.warning_amber_rounded);
    });

    test('info resolves correct defaults', () {
      final c = t.resolve(SnackBarType.info);
      expect(c.backgroundColor, const Color(0xFF003249));
      expect(c.icon, Icons.info_outline_rounded);
    });

    test('custom color overrides default', () {
      const custom = AppSnackBarTheme(successColor: Colors.teal);
      expect(custom.resolve(SnackBarType.success).backgroundColor, Colors.teal);
    });

    test('custom icon overrides default', () {
      const custom = AppSnackBarTheme(errorIcon: Icons.cancel);
      expect(custom.resolve(SnackBarType.error).icon, Icons.cancel);
    });

    test('default borderRadius is 16', () => expect(t.borderRadius, 16));
    test('default elevation is 6', () => expect(t.elevation, 6));
    test('default fontSize is 14', () => expect(t.fontSize, 14));
    test('default animation is slide', () {
      expect(t.defaultAnimation, SnackBarAnimation.slide);
    });
  });

  // ── Enum tests ──────────────────────────────────────────────────────────────

  group('SnackBarType', () {
    test('has 4 values', () => expect(SnackBarType.values.length, 4));
  });

  group('SnackBarPosition', () {
    test('has 2 values', () => expect(SnackBarPosition.values.length, 2));
  });

  group('SnackBarAnimation', () {
    test('has 3 values', () => expect(SnackBarAnimation.values.length, 3));
  });

  // ── AppSnackBar static config ────────────────────────────────────────────────

  group('AppSnackBar static config', () {
    tearDown(() {
      AppSnackBar.messengerKey = null;
      AppSnackBar.useQueue = false;
      AppSnackBar.theme = const AppSnackBarTheme();
    });

    test('messengerKey is null by default', () {
      expect(AppSnackBar.messengerKey, isNull);
    });

    test('useQueue is false by default', () {
      expect(AppSnackBar.useQueue, isFalse);
    });

    test('queueLength is 0 by default', () {
      expect(AppSnackBar.queueLength, 0);
    });

    test('messengerKey can be set and read', () {
      final key = GlobalKey<ScaffoldMessengerState>();
      AppSnackBar.messengerKey = key;
      expect(AppSnackBar.messengerKey, equals(key));
    });
  });

  // ── Widget tests ─────────────────────────────────────────────────────────────

  group('AppSnackBar widget tests', () {
    setUp(() {
      AppSnackBar.messengerKey = null;
      AppSnackBar.useQueue = false;
      AppSnackBar.theme = const AppSnackBarTheme();
    });

    testWidgets('success shows message', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.success(ctx, 'Profile saved!'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Profile saved!'), findsOneWidget);
    });

    testWidgets('error shows message', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.error(ctx, 'Upload failed!'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Upload failed!'), findsOneWidget);
    });

    testWidgets('warning shows message', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.warning(ctx, 'Low storage'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Low storage'), findsOneWidget);
    });

    testWidgets('info shows message', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.info(ctx, 'Update available'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Update available'), findsOneWidget);
    });

    testWidgets('close button dismisses snackbar', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.info(ctx, 'Close me'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Close me'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Close me'), findsNothing);
    });

    testWidgets('showWithAction shows action label', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.showWithAction(
              ctx,
              'Deleted.',
              actionLabel: 'Undo',
              onAction: () {},
            ),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Deleted.'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('showWithAction calls onAction callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.showWithAction(
              ctx,
              'Deleted.',
              actionLabel: 'Undo',
              onAction: () => called = true,
            ),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('showLoading shows spinner', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.showLoading(ctx, 'Uploading...'),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hide dismisses snackbar', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => Column(
            children: [
              ElevatedButton(
                onPressed: () => AppSnackBar.info(ctx, 'Hiding me'),
                child: const Text('show'),
              ),
              ElevatedButton(
                onPressed: () => AppSnackBar.hide(ctx),
                child: const Text('hide'),
              ),
            ],
          ),
        ),
      ));
      await tester.tap(find.text('show'));
      await tester.pump();
      expect(find.text('Hiding me'), findsOneWidget);

      await tester.tap(find.text('hide'));
      await tester.pumpAndSettle();
      expect(find.text('Hiding me'), findsNothing);
    });

    testWidgets('messengerKey works instead of context', (tester) async {
      final key = GlobalKey<ScaffoldMessengerState>();
      AppSnackBar.messengerKey = key;

      await tester.pumpWidget(testApp(
        messengerKey: key,
        body: ElevatedButton(
          onPressed: () => AppSnackBar.success(null, 'From key!'),
          child: const Text('tap'),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.text('From key!'), findsOneWidget);
    });

    testWidgets('fade animation applies FadeTransition', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.info(
              ctx,
              'Fade in',
              animation: SnackBarAnimation.fade,
            ),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('slide animation applies SlideTransition', (tester) async {
      await tester.pumpWidget(testApp(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => AppSnackBar.info(
              ctx,
              'Slide in',
              animation: SnackBarAnimation.slide,
            ),
            child: const Text('tap'),
          ),
        ),
      ));
      await tester.tap(find.text('tap'));
      await tester.pump();
      expect(find.byType(SlideTransition), findsOneWidget);
    });
  });

  // ── SnackBarQueue unit tests ──────────────────────────────────────────────────

  group('SnackBarQueue', () {
    testWidgets('queue length increases on add', (tester) async {
      final key = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(testApp(messengerKey: key));

      final queue = SnackBarQueue(messengerKey: key);
      expect(queue.length, 0);
      expect(queue.isProcessing, isFalse);
    });

    testWidgets('clear resets queue', (tester) async {
      final key = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(testApp(messengerKey: key));
      final queue = SnackBarQueue(messengerKey: key);
      queue.clear();
      expect(queue.length, 0);
      expect(queue.isProcessing, isFalse);
    });
  });
}
