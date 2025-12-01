import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bins/bins_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Row(
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.dashboard, color: Colors.white),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: signUserOut,
              icon: const Icon(Icons.logout, color: Colors.red),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Welcome card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 48, color: Colors.green[700]),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? 'User',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bins list
              const Text(
                'Smart Bins',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  if (!isMobile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Bin",
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Location",
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Type",
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          "Fill Level",
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Status",
                          style: headerStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  children: const [
                    BinRow(
                      binId: "01",
                      location: "Canteen",
                      type: "Biodegradable",
                      fillLevel: 50,
                      status: "Low",
                    ),
                    BinRow(
                      binId: "02",
                      location: "hallway",
                      type: "Non-Biodegradable",
                      fillLevel: 60,
                      status: "Medium",
                    ),
                    BinRow(
                      binId: "02",
                      location: "hallway",
                      type: "Non-Biodegradable",
                      fillLevel: 60,
                      status: "Medium",
                    ),
                    BinRow(
                      binId: "02",
                      location: "hallway",
                      type: "Non-Biodegradable",
                      fillLevel: 60,
                      status: "Medium",
                    ),
                    BinRow(
                      binId: "02",
                      location: "hallway",
                      type: "Non-Biodegradable",
                      fillLevel: 60,
                      status: "Medium",
                    ),
                    BinRow(
                      binId: "02",
                      location: "hallway",
                      type: "Non-Biodegradable",
                      fillLevel: 60,
                      status: "Medium",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const headerStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
