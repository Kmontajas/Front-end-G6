import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> bins = [];
  List<dynamic> alerts = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final binData = await ApiService.getBins();
      final alertData = await ApiService.getAlerts();
      setState(() {
        bins = binData;
        alerts = alertData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Trash Bin Web Dashboard")),
      body: RefreshIndicator(
        onRefresh: () async => fetchData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Bins", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...bins.map((bin) => Card(
                  child: ListTile(
                    title: Text(bin['name'] ?? bin['binId']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Type: ${bin['type']}"),
                        Text("Level: ${bin['level']}%"),
                        Text("Latest Classification: ${bin['latest_classification'] ?? 'N/A'}"),
                        Text("Active Alerts: ${bin['active_alerts']?.length ?? 0}"),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            const Text("Alerts", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ...alerts.map((alert) => Card(
                  color: Colors.red[100],
                  child: ListTile(
                    title: Text(alert['alert_type']),
                    subtitle: Text(DateTime.parse(alert['timestamp']).toLocal().toString()),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
