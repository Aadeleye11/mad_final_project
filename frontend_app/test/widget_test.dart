import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_app/data/repositories/preferences_repository.dart';
import 'package:frontend_app/main.dart';

Future<MyApp> buildApp({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  return MyApp(preferencesRepository: PreferencesRepository(sharedPrefs));
}

Future<void> pumpToLogin(WidgetTester tester, MyApp app) async {
  await tester.pumpWidget(app);
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).first,
    'emeka@example.com',
  );
  await tester.enterText(find.byType(TextFormField).last, 'secret123');
  await tester.tap(find.text('Log in'));
  // Mock repository resolves after 1.2s.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Splash shows branding then navigates to login',
      (WidgetTester tester) async {
    await pumpToLogin(tester, await buildApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (WidgetTester tester) async {
    await pumpToLogin(tester, await buildApp());

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('First login goes to interest selection, then home',
      (WidgetTester tester) async {
    await pumpToLogin(tester, await buildApp());
    await login(tester);

    expect(find.text('What are you into?'), findsOneWidget);

    // Button disabled until a selection is made.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Generate my itinerary'),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text('Gorillas & Wildlife'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate my itinerary'));
    await tester.pumpAndSettle();

    expect(find.text('Good morning, emeka'), findsOneWidget);
  });

  testWidgets('Returning user skips interest selection',
      (WidgetTester tester) async {
    await pumpToLogin(
      tester,
      await buildApp(prefs: {
        'interests_completed_emeka@example.com': true,
        'interests_emeka@example.com': ['History'],
      }),
    );
    await login(tester);

    expect(find.text('Good morning, emeka'), findsOneWidget);
    expect(find.text('What are you into?'), findsNothing);
  });

  testWidgets('Interests are editable from home in settings mode',
      (WidgetTester tester) async {
    await pumpToLogin(
      tester,
      await buildApp(prefs: {
        'interests_completed_emeka@example.com': true,
        'interests_emeka@example.com': ['History'],
      }),
    );
    await login(tester);

    await tester.tap(find.text('Edit interests'));
    await tester.pumpAndSettle();

    // Settings mode: previously saved chip is selected, save button shown.
    expect(find.text('My Interests'), findsOneWidget);
    expect(find.text('Save interests'), findsOneWidget);

    await tester.tap(find.text('Lakes & Nature'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save interests'));
    await tester.pumpAndSettle();

    expect(find.text('Interests updated'), findsOneWidget);
    expect(find.text('Good morning, emeka'), findsOneWidget);
  });

  testWidgets('Sign up link opens signup screen and validates passwords match',
      (WidgetTester tester) async {
    await pumpToLogin(tester, await buildApp());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Emeka Daniels');
    await tester.enterText(fields.at(1), 'emeka@example.com');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'different');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Successful signup goes to interest selection',
      (WidgetTester tester) async {
    await pumpToLogin(tester, await buildApp());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Emeka Daniels');
    await tester.enterText(fields.at(1), 'emeka@example.com');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');
    await tester.tap(find.text('Create account'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('What are you into?'), findsOneWidget);
  });
}
