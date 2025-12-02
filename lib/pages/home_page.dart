import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bins/bins_row.dart';
import 'package:flutter_application_1/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<dynamic>> _binsStream;
  List<dynamic> _binsCache = [];
  StreamSubscription<List<dynamic>>? _binsSub;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _binsStream = ApiService.streamBins();

    // keep a local cache that we can update immediately on delete/create
    _binsSub = _binsStream.listen((bins) {
      setState(() {
        _binsCache = bins;
        _loading = false;
        _errorMessage = null; // Clear error on successful fetch
      });
    }, onError: (e) {
      // keep using cache on errors
      String errorMsg = 'Failed to load bins';

      if (e is SocketException) {
        errorMsg = 'Network error: Please check your internet connection';
      } else if (e is TimeoutException) {
        errorMsg = 'Request timeout: Server took too long to respond';
      } else if (e.toString().contains('Connection refused')) {
        errorMsg = 'Server connection failed';
      } else if (e.toString().contains('Network is unreachable')) {
        errorMsg = 'Network is unreachable';
      }

      setState(() {
        _loading = false;
        _errorMessage = errorMsg;
      });

      // Show snackbar notification for GET/stream error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _binsSub?.cancel();
    super.dispose();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // helper to extract id from backend bin object
  String _extractId(dynamic item) {
    if (item is Map<String, dynamic>) {
      return (item['binId'] ?? item['bin_id'] ?? item['id'] ?? item['_id'] ?? '').toString();
    }
    return item.toString();
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
            const Icon(Icons.dashboard, color: Colors.white),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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

              // Real-time list rendered from local cache (_binsCache)
              Expanded(
                child: Builder(builder: (context) {
                  if (_loading) return const Center(child: CircularProgressIndicator());

                  // Show error message if stream failed
                  if (_errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                                _loading = true;
                                _binsSub?.cancel();
                                _binsStream = ApiService.streamBins();
                                _binsSub = _binsStream.listen((bins) {
                                  setState(() {
                                    _binsCache = bins;
                                    _loading = false;
                                    _errorMessage = null;
                                  });
                                }, onError: (e) {
                                  setState(() {
                                    _loading = false;
                                    _errorMessage = 'Failed to load bins';
                                  });
                                });
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final bins = _binsCache;
                  if (bins.isEmpty) return const Center(child: Text('No bins available'));

                  return ListView.builder(
                    itemCount: bins.length,
                    itemBuilder: (context, index) {
                      final item = bins[index] as Map<String, dynamic>;

                      final binId = (item['binId'] ?? item['bin_id'] ?? item['id'] ?? item['_id'] ?? '').toString();
                      final location = (item['location'] ?? 'Unknown').toString();
                      final type = (item['type'] ?? 'Unknown').toString();

                      int fillLevel = 0;
                      final rawFill = item['fill_level'] ?? item['fillLevel'] ?? item['distance_cm'];
                      if (rawFill is num) {
                        fillLevel = rawFill.round();
                      } else if (rawFill is String) {
                        fillLevel = int.tryParse(rawFill) ?? 0;
                      }

                      final status = (item['status'] ?? 'Unknown').toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: BinRow(
                                binId: binId,
                                location: location,
                                type: type,
                                fillLevel: fillLevel,
                                status: status,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete bin',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirm delete'),
                                    content: Text('Delete bin "\$binId"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm != true) return;
                                try {
                                  await ApiService.deleteBin(binId);

                                  if (mounted) {
                                    setState(() {
                                      _binsCache.removeWhere((b) => _extractId(b) == binId);
                                    });
                                  }

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Bin deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delete failed: \\${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
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
