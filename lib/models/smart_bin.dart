class SmartBin {
  final String id;
  final String type;
  final String status;
  final int fillLevel;
  final String location;

  SmartBin({
    required this.id,
    required this.type,
    required this.status,
    required this.fillLevel,
    required this.location,
  });

  factory SmartBin.fromJson(Map<String, dynamic> json) {
    return SmartBin(
      id: json["_id"],
      type: json["type"],
      status: json["status"],
      fillLevel: json["fillLevel"],
      location: json["location"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "status": status,
      "fillLevel": fillLevel,
      "location": location,
    };
  }
}
