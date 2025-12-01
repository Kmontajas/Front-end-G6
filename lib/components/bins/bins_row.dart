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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return InkWell(
      // onTap: () {}, // navigation if needed
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 8),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
    );
  }

  Widget _buildMobileLayout() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 5, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowLabelValue("Bin ID", binId),
          _rowLabelValue("Location", location),
          _rowLabelWidget("Type", BinTypeTag(type: type)),
          _rowLabelWidget(
            "Status",
            StatusTag(label: status, color: getStatusColor()),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: fillLevel / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.black87),
          ),
          Text("Fill level: $fillLevel%"),
        ],
      ),
    );
  }

  Widget _rowLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _rowLabelWidget(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          widget,
        ],
      ),
    );
  }
}
