import 'package:flutter/material.dart';

class BinTypeTag extends StatelessWidget {
  final String type;

  const BinTypeTag({required this.type, super.key});

  Color getTypeCOlor() {
    switch (type) {
      case "Biodegradable":
        return Colors.green.shade100;
      case "Recyclable":
        return Colors.blue.shade100;
      case "Non-Biodegradable":
        return Colors.redAccent;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: getTypeCOlor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
