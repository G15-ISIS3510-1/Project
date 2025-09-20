import 'package:flutter/material.dart';

class HostView extends StatefulWidget {
  const HostView({super.key});
  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> {
  final _c = List.generate(4, (_) => TextEditingController());
  final _f = List.generate(4, (_) => FocusNode());
  String get _pin => _c.map((e) => e.text).join();
  void _onChanged(int i, String value) {
    if (value.length > 1) {
      _c[i].text = value.characters.last;
      _c[i].selection = TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && i < 3) {
      _f[i + 1].requestFocus();
    }
    setState(() {});
  }

  void _submit() {
    debugPrint('PIN ingresado: $_pin');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(32, 32, 32, 76 + 12 + bottomInset + 8),
        children: [
          Center(
            child: Transform.scale(
              scaleY: 0.82,
              child: const Text(
                'QOVO',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: -7.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Host PIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              return SizedBox(
                width: 64,
                child: TextField(
                  controller: _c[i],
                  focusNode: _f[i],
                  onChanged: (v) => _onChanged(i, v),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _pin.length == 4 ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enter'),
            ),
          ),
        ],
      ),
    );
  }
}
