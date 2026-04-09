import 'package:flutter/material.dart';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

// ─────────────────────────────────────────────
// CALL SCREEN PAGE
// ─────────────────────────────────────────────
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _dialValue = '';
  final String _defaultEmergencyNumber = '112'; // Default emergency/help desk number

  void _appendDigit(String digit) {
    setState(() => _dialValue += digit);
  }

  void _delete() {
    if (_dialValue.isNotEmpty) {
      setState(
        () => _dialValue = _dialValue.substring(0, _dialValue.length - 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4793A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Call screen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/home_screen'),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Quick Dial Label ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Quick Dial',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Contact Chip ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dialValue.isEmpty ? 'Renel Help Desk' : _dialValue,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // The Delete Button
                  if (_dialValue.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.backspace_outlined,
                        color: Color(0xFFD4793A),
                      ),
                      onPressed: _delete,
                    ),
                  // The Three-Dot Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clear',
                        child: Text('Clear All'),
                      ),
                      const PopupMenuItem(
                        value: 'save',
                        child: Text('Save Contact'),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'clear') setState(() => _dialValue = '');
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Dial Pad ──
          Expanded(
            child: _DialPad(onDigitTap: _appendDigit, onDelete: _delete),
          ),

          // ── Call Button ──
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: () async {
                final numberToCall = _dialValue.isEmpty ? _defaultEmergencyNumber : _dialValue;
                await FlutterPhoneDirectCaller.callNumber(numberToCall);
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialPad extends StatelessWidget {
  final void Function(String) onDigitTap;
  final VoidCallback onDelete;

  const _DialPad({required this.onDigitTap, required this.onDelete});

  static const List<List<Map<String, String>>> _rows = [
    [
      {'digit': '1', 'sub': ''},
      {'digit': '2', 'sub': 'ABC'},
      {'digit': '3', 'sub': 'DEF'},
    ],
    [
      {'digit': '4', 'sub': 'GHI'},
      {'digit': '5', 'sub': 'JKL'},
      {'digit': '6', 'sub': 'MNO'},
    ],
    [
      {'digit': '7', 'sub': 'PQRS'},
      {'digit': '8', 'sub': 'TUV'},
      {'digit': '9', 'sub': 'WXYZ'},
    ],
    [
      {'digit': '*', 'sub': ''},
      {'digit': '0', 'sub': '+'},
      {'digit': '#', 'sub': ''},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return _DialKey(
                digit: key['digit']!,
                sub: key['sub']!,
                onTap: () => onDigitTap(key['digit']!),
                onLongPress: () {
                  if (key['digit'] == '0') {
                    onDigitTap('+');
                  }
                },
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _DialKey extends StatelessWidget {
  final String digit;
  final String sub;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DialKey({
    required this.digit,
    required this.sub,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
