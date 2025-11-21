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
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final binData = await ApiService.getBins();
      final alertData = await ApiService.getAlerts();
      setState(() {
        bins = binData ?? [];
        alerts = alertData ?? [];
        isLoading = false;
      });
    } catch (e, st) {
      // keep short: print so you can inspect terminal/console
      print('Error fetching data: $e\n$st');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Trash Bin Web Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: (error != null)
                  ? ListView(
                      // Keep it scrollable so RefreshIndicator works
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.error_outline, size: 72, color: Colors.red[400]),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Failed to load data.\n$error',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: fetchData,
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text("Bins", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (bins.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox, size: 48, color: Colors.grey[500]),
                                  const SizedBox(height: 8),
                                  Text('No bins available', style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          )
                        else
                          ...bins.map((bin) => Card(
                                child: ListTile(
                                  title: Text(bin['name'] ?? bin['binId'] ?? 'Unnamed'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Type: ${bin['type'] ?? 'N/A'}"),
                                      Text("Level: ${bin['level'] ?? 'N/A'}%"),
                                      Text("Latest Classification: ${bin['latest_classification'] ?? 'N/A'}"),
                                      Text("Active Alerts: ${bin['active_alerts']?.length ?? 0}"),
                                    ],
                                  ),
                                ),
                              )),
                        const SizedBox(height: 20),
                        const Text("Alerts", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (alerts.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.notifications_off, size: 48, color: Colors.grey[500]),
                                  const SizedBox(height: 8),
                                  Text('No active alerts', style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          )
                        else
                          ...alerts.map((alert) => Card(
                                color: Colors.red[100],
                                child: ListTile(
                                  title: Text(alert['alert_type'] ?? 'Alert'),
                                  subtitle: Text(
                                    // guard timestamp parsing
                                    (alert['timestamp'] != null)
                                        ? DateTime.tryParse(alert['timestamp'])?.toLocal().toString() ?? alert['timestamp'].toString()
                                        : 'Unknown time',
                                  ),
                                ),
                              )),
                      ],
                    ),
            ),
    );
  }
}
