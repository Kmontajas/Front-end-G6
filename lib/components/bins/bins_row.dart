import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bins/bin_status.dart';
import 'package:flutter_application_1/components/bins/bin_type.dart';

class BinRow extends StatelessWidget {
  final String binId;
  final String location;
  final String type;
  final int fillLevel;
  final String status;

  const BinRow({
    required this.binId,
    required this.location,
    required this.type,
    required this.fillLevel,
    required this.status,
    super.key,
  });

  Color getStatusColor() {
    switch (status) {
      case "Full":
        return Colors.red;
      case "High":
        return Colors.orange;
      case "Medium":
        return Colors.amber;
      case "Low":
        return Colors.lightGreen;
      case "Empty":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () {}, // navigation
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Expanded(flex: 2, child: Center(child: Text(binId))),
            Expanded(flex: 3, child: Center(child: Text(location))),
            Expanded(
              flex: 4,
              child: Center(child: BinTypeTag(type: type)),
            ),

            Expanded(
              flex: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: fillLevel / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(Colors.black87),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("$fillLevel%"),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: StatusTag(label: status, color: getStatusColor()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
