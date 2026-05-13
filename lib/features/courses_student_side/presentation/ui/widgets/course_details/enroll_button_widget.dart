import 'package:flutter/material.dart';

class EnrollButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const EnrollButtonWidget({super.key, this.onTap = _empty});

  static void _empty() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff3E86F5),
          ),
          child: const Text("Enroll in Course"),
        ),
      ),
    );
  }
}
