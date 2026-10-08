import 'package:flutter/material.dart';

import 'calculator_button.dart';

class CalculationEntry {
  const CalculationEntry(this.expression, this.result);

  final String expression;
  final String result;
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForOperand = false;
  bool _showingResult = false;
  String? _error;
  final List<CalculationEntry> _history = [];

  // Bound input and results to a range where double arithmetic is useful.
  static const int _maxInputDigits = 12;
  static const double _maxMagnitude = 1e12;

  void _clearAll() {
    setState(() {
      _input = '0';
      _firstOperand = null;
      _operator = null;
      _waitingForOperand = false;
      _showingResult = false;
      _error = null;
    });
  }

  void _prepareInput() {
    if (_showingResult) {
      _firstOperand = null;
      _operator = null;
    }
    if (_waitingForOperand || _showingResult) _input = '0';
    _waitingForOperand = false;
    _showingResult = false;
    _error = null;
  }

  void _inputDigit(String digit) {
    setState(() {
      _prepareInput();
      if (_input.replaceAll(RegExp(r'[^0-9]'), '').length >= _maxInputDigits) {
        _error = 'Use at most $_maxInputDigits digits per number.';
        return;
      }
      _input = _input == '0' ? digit : '$_input$digit';
    });
  }

  void _inputDecimal() {
    setState(() {
      _prepareInput();
      if (_input.contains('.')) {
        _error = 'This number already has a decimal point.';
        return;
      }
      _input = '$_input.';
    });
  }

  void _selectOperator(String selectedOperator) {
    setState(() {
      if (_operator != null && !_waitingForOperand) {
        _error = 'Press equals before starting another operation.';
        return;
      }
      _firstOperand = double.parse(_input);
      _operator = selectedOperator;
      _waitingForOperand = true;
      _showingResult = false;
      _error = null;
    });
  }

  String _formatNumber(double value) {
    // Twelve significant digits hide ordinary floating point artifacts.
    final rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded == 0) return '0';
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    return rounded.toString();
  }

  void _calculate() {
    setState(() {
      if (_firstOperand == null || _operator == null || _waitingForOperand) {
        _error = 'Enter a first number, an operator, and a second number.';
        return;
      }
      final secondOperand = double.parse(_input);
      if (_operator == '÷' && secondOperand == 0) {
        _error = 'Cannot divide by zero. Edit the second number or press AC.';
        return;
      }
      final double result;
      switch (_operator) {
        case '+':
          result = _firstOperand! + secondOperand;
        case '−':
          result = _firstOperand! - secondOperand;
        case '×':
          result = _firstOperand! * secondOperand;
        case '÷':
          result = _firstOperand! / secondOperand;
        default:
          _error = 'Choose a valid operator.';
          return;
      }
      if (!result.isFinite || result.abs() >= _maxMagnitude) {
        _error = 'Result is too large. Use smaller numbers or press AC.';
        return;
      }
      if (result == 0 &&
          _firstOperand != 0 &&
          secondOperand != 0 &&
          (_operator == '×' || _operator == '÷')) {
        _error = 'Result is too small to display accurately.';
        return;
      }
      final formatted = _formatNumber(result);
      _history.insert(
        0,
        CalculationEntry(
          '${_formatNumber(_firstOperand!)} $_operator '
          '${_formatNumber(secondOperand)} = $formatted',
          formatted,
        ),
      );
      _input = formatted;
      _firstOperand = null;
      _operator = null;
      _waitingForOperand = false;
      _showingResult = true;
      _error = null;
    });
  }

  void _backspace({bool clearEntry = false}) {
    setState(() {
      _error = null;
      if (_waitingForOperand) return;
      // Results may use scientific notation; clear them instead of editing it.
      if (_showingResult || clearEntry) {
        _input = '0';
      } else {
        _input = _input.length > 1
            ? _input.substring(0, _input.length - 1)
            : '0';
        if (_input == '-') _input = '0';
      }
      _showingResult = false;
    });
  }

  void _reuseHistory(CalculationEntry entry) {
    setState(() {
      _input = entry.result;
      _firstOperand = null;
      _operator = null;
      _waitingForOperand = false;
      _showingResult = true;
      _error = null;
    });
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Calculation history',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(_history.clear);
                          updateSheet(() {});
                        },
                        child: const Text('Clear History'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _history.isEmpty
                      ? const Center(child: Text('No calculations yet.'))
                      : ListView.builder(
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final entry = _history[index];
                            return ListTile(
                              title: Text(entry.expression),
                              subtitle: const Text('Tap to reuse result'),
                              onTap: () {
                                _reuseHistory(entry);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(
    String label,
    String semanticLabel,
    VoidCallback action, {
    int flex = 1,
    bool highlighted = false,
    VoidCallback? onLongPress,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CalculatorButton(
          key: ValueKey('button-$label'),
          label: label,
          semanticLabel: semanticLabel,
          onPressed: action,
          onLongPress: onLongPress,
          highlighted: highlighted,
        ),
      ),
    );
  }

  Widget _digit(String digit) =>
      _button(digit, digit, () => _inputDigit(digit));

  Widget _operation(String symbol, String name) =>
      _button(symbol, name, () => _selectOperator(symbol), highlighted: true);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _operator == null
                                    ? (_showingResult
                                          ? 'Result'
                                          : 'Enter a number')
                                    : '${_formatNumber(_firstOperand!)} $_operator',
                              ),
                              const SizedBox(height: 12),
                              Semantics(
                                liveRegion: true,
                                label: 'Display: $_input',
                                excludeSemantics: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  child: Text(
                                    _input,
                                    key: const ValueKey('display'),
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_error != null)
                          Semantics(
                            liveRegion: true,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Error: $_error',
                                style: TextStyle(color: colors.error),
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _showHistory,
                            icon: const Icon(Icons.history),
                            label: Text('History (${_history.length})'),
                          ),
                        ),
                        Row(
                          children: [
                            _button('AC', 'All clear', _clearAll, flex: 2),
                            _button(
                              '⌫',
                              'Backspace. Hold to clear entry.',
                              _backspace,
                              onLongPress: () => _backspace(clearEntry: true),
                            ),
                            _operation('÷', 'Divide'),
                          ],
                        ),
                        Row(
                          children: [
                            _digit('7'),
                            _digit('8'),
                            _digit('9'),
                            _operation('×', 'Multiply'),
                          ],
                        ),
                        Row(
                          children: [
                            _digit('4'),
                            _digit('5'),
                            _digit('6'),
                            _operation('−', 'Subtract'),
                          ],
                        ),
                        Row(
                          children: [
                            _digit('1'),
                            _digit('2'),
                            _digit('3'),
                            _operation('+', 'Add'),
                          ],
                        ),
                        Row(
                          children: [
                            _button('0', '0', () => _inputDigit('0'), flex: 2),
                            _button('.', 'Decimal point', _inputDecimal),
                            _button(
                              '=',
                              'Equals',
                              _calculate,
                              highlighted: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
