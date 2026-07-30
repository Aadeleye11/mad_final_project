import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_app/main.dart';

void main() {
  testWidgets('Splash shows branding then navigates to login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('RwandaGo'), findsOneWidget);
    expect(
      find.text('Your offline-first Rwanda travel companion'),
      findsOneWidget,
    );

    // Let the splash timer fire and the navigation settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Successful login reaches home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'emeka@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Log in'));

    // Mock repository resolves after 1.2s.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, emeka'), findsOneWidget);
  });
}
