# Calculator App

CSC 6370 Mobile Application Development assignment — graduate pathway.

A small Flutter calculator built inside the existing project using Material widgets, a StatefulWidget, and setState. No packages were added.

## Features

- Digits 0–9, addition (+), subtraction (−), multiplication (×), division (÷), equals, and AC.
- Mandatory decimal support for all operations; duplicate decimal points are rejected and whole results omit `.0`.
- **Calculation History:** scrollable session history in a bottom sheet, tap to reuse a result, and Clear History.
- **Backspace/Delete:** remove the last input character; hold to clear the current entry. Backspace after a result clears that result.
- **Advanced Error Handling:** recoverable messages for incomplete operations, zero division (including 0 ÷ 0), duplicate decimals, input limits, and oversized/non-finite results.
- Responsive portrait layout with scrolling for short screens and enlarged text; labeled controls and announced results/errors.

## Run and build

From this project directory with Flutter installed:

```sh
flutter pub get
flutter run
flutter build apk --release
```

The release APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Testing

```sh
dart format lib test
flutter analyze
flutter test
```

Use `TESTING.md` on an emulator or Android device and fill in the blank observed-result and pass/fail columns. Automated widget tests do not establish device usability or screen-reader behavior.

## State and behavior

`CalculatorPage` stores the editable input string, first operand, selected operator, flags for awaiting input and displaying a result, an optional error, and a session history list. Helper methods change these values inside `setState`. `CalculatorButton` provides reusable Material buttons.

Enter the first operand, choose an operator, enter the second operand, and press equals. Before the second operand starts, another operator replaces the pending operator. After the second operand starts, press equals before choosing another operator. This is a two-operand calculator; it does not parse chained expressions. After a result, digits start fresh and an operator reuses the result.

AC resets the calculation but retains history; Clear History deletes history. Errors preserve input for correction. Results use approximately 12 significant digits, with magnitudes below 10¹² and at most 12 input digits. Ordinary floating point rounding still applies.
