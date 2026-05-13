import 'package:flutter/material.dart';

class TabButtonWidget extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const TabButtonWidget({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xff4A90E2) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xffD9DCE1)),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
