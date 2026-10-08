import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> press(WidgetTester tester, List<String> buttons) async {
  for (final button in buttons) {
    final finder = find.byKey(ValueKey('button-$button'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

String display(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('display'))).data!;

void main() {
  final cases = <String, List<String>>{
    '10': ['8', '+', '2', '='],
    '5': ['9', '−', '4', '='],
    '42': ['7', '×', '6', '='],
    '4': ['8', '÷', '2', '='],
    '7.7': ['5', '.', '5', '+', '2', '.', '2', '='],
    '10 subtraction': ['1', '0', '.', '5', '−', '0', '.', '5', '='],
    '10 multiplication': ['2', '.', '5', '×', '4', '='],
    '3': ['7', '.', '5', '÷', '2', '.', '5', '='],
  };
  for (final entry in cases.entries) {
    testWidgets('Arithmetic: ${entry.key}', (tester) async {
      await tester.pumpWidget(const MyApp());
      await press(tester, entry.value);
      expect(display(tester), entry.key.split(' ').first);
      expect(find.text('History (1)'), findsOneWidget);
    });
  }

  testWidgets('Incomplete equals and zero division recover safely', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['=']);
    expect(find.textContaining('Enter a first number,'), findsOneWidget);
    await press(tester, ['8', '÷', '=']);
    expect(find.textContaining('Enter a first number,'), findsOneWidget);
    await press(tester, ['0', '=']);
    expect(find.textContaining('Cannot divide by zero'), findsOneWidget);
    await press(tester, ['⌫', '2', '=']);
    expect(display(tester), '4');
    await press(tester, ['AC', '0', '÷', '0', '=']);
    expect(find.textContaining('Cannot divide by zero'), findsOneWidget);
    await press(tester, ['AC', '3']);
    expect(display(tester), '3');
    expect(find.textContaining('Error:'), findsNothing);
  });

  testWidgets('Decimals, operator replacement, and backspace', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['1', '.', '2', '.']);
    expect(display(tester), '1.2');
    expect(find.textContaining('already has a decimal'), findsOneWidget);
    await press(tester, ['⌫']);
    expect(display(tester), '1.');
    await press(tester, ['⌫']);
    expect(display(tester), '1');
    await tester.longPress(find.byKey(const ValueKey('button-⌫')));
    await tester.pumpAndSettle();
    expect(display(tester), '0');
    await press(tester, ['8', '+', '×', '2', '+']);
    expect(find.textContaining('Press equals'), findsOneWidget);
    await press(tester, ['=']);
    expect(display(tester), '16');
    await press(tester, ['⌫']);
    expect(display(tester), '0');
  });

  testWidgets('History reuse, clear, and fresh input after results', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, ['8', '+', '2', '=']);
    await tester.tap(find.text('History (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8 + 2 = 10'));
    await tester.pumpAndSettle();
    expect(display(tester), '10');
    await press(tester, ['×', '5', '=']);
    expect(display(tester), '50');
    await press(tester, ['7']);
    expect(display(tester), '7');
    await tester.tap(find.text('History (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear History'));
    await tester.pumpAndSettle();
    expect(find.text('No calculations yet.'), findsOneWidget);
  });

  testWidgets('Large results and digit limits report errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    await press(tester, List.filled(13, '9'));
    expect(display(tester), '999999999999');
    expect(find.textContaining('at most 12 digits'), findsOneWidget);
    await press(tester, ['×', '9', '=']);
    expect(find.textContaining('Result is too large'), findsOneWidget);
    expect(find.text('History (0)'), findsOneWidget);
  });

  testWidgets('Small screen and enlarged text have no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const MyApp(),
      ),
    );
    await press(tester, ['8', '÷', '0', '=']);
    expect(tester.takeException(), isNull);
  });
}
