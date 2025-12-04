import 'dart:async';
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
  late Stream<List<Map<String, dynamic>>> _binsStream;
  List<Map<String, dynamic>> _binsCache = [];
  StreamSubscription<List<Map<String, dynamic>>>? _binsSub;

  bool _loading = true;
  String? _errorMessage;

  final Set<String> _shownAlerts = {}; // track which bins have triggered FULL popup

  @override
  void initState() {
    super.initState();

    // ===== BINS STREAM =====
    _binsStream = ApiService.streamBins().map((list) =>
        list.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    _binsSub = _binsStream.listen((bins) {
      setState(() {
        _binsCache = bins;
        _loading = false;
        _errorMessage = null;
      });

      // Check for FULL bins and show popup
      for (var bin in bins) {
        final binId = _extractId(bin);
        final status = bin['status'] ?? 'OK';

        if (status == "FULL" && !_shownAlerts.contains(binId)) {
          _shownAlerts.add(binId);

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (ctx) => AlertDialog(
                title: const Text('🚨 Bin FULL Alert'),
                content: Text('Bin $binId is FULL!'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            );
          }
        }
      }

      // Remove bins from _shownAlerts if they are no longer FULL
      for (var id in _shownAlerts.toList()) {
        final bin = _binsCache.firstWhere(
          (b) => _extractId(b) == id,
          orElse: () => {},
        );
        if (bin.isEmpty || (bin['status'] ?? '') != "FULL") {
          _shownAlerts.remove(id);
        }
      }
    }, onError: (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load bins: $e';
      });
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

  String _extractId(dynamic item) {
    if (item is Map<String, dynamic>) {
      return (item['binId'] ?? item['bin_id'] ?? item['id'] ?? item['_id'] ?? '').toString();
    }
    return item.toString();
  }

  Future<void> _deleteBin(String binId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text('Delete bin "$binId"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiService.deleteBin(binId);
      setState(() => _binsCache.removeWhere((b) => _extractId(b) == binId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bin deleted successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ===== CREATE BIN =====
  Future<void> _createBin() async {
    String binId = '';
    String location = '';
    String type = 'recyclable'; // default type

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Bin'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bin ID'),
                onSaved: (value) => binId = value?.trim() ?? '',
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter bin ID' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) => location = value?.trim() ?? '',
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter location' : null,
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'recyclable', child: Text('Recyclable')),
                  DropdownMenuItem(value: 'biodegradable', child: Text('Biodegradable')),
                  DropdownMenuItem(value: 'non_biodegradable', child: Text('Non-Biodegradable')),
                ],
                onChanged: (value) => type = value ?? 'recyclable',
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Create bin in Firebase
        await ApiService.createBin({
          'binId': binId,
          'location': location,
          'type': type,
          'fill_level': 0,
          'fill_level_percent': 0,
          'status': 'OK',
        });

        // Optimistically update UI
        setState(() {
          _binsCache.add({
            'binId': binId,
            'location': location,
            'type': type,
            'fill_level': 0,
            'fill_level_percent': 0,
            'status': 'OK',
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bin created successfully'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
            const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            const SizedBox(width: 10),
            const Icon(Icons.dashboard, color: Colors.white),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout, color: Colors.red)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBin,
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
                          const Text('Welcome!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(user?.email ?? 'User', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Smart Bins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (!isMobile)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Expanded(flex: 2, child: Text("Bin", style: headerStyle, textAlign: TextAlign.center)),
                    Expanded(flex: 3, child: Text("Location", style: headerStyle, textAlign: TextAlign.center)),
                    Expanded(flex: 4, child: Text("Type", style: headerStyle, textAlign: TextAlign.center)),
                    Expanded(flex: 6, child: Text("Fill Level", style: headerStyle, textAlign: TextAlign.center)),
                    Expanded(flex: 3, child: Text("Status", style: headerStyle, textAlign: TextAlign.center)),
                  ],
                ),
              const Divider(),
              Expanded(
                child: Builder(builder: (context) {
                  if (_loading) return const Center(child: CircularProgressIndicator());
                  if (_errorMessage != null) return Center(child: Text(_errorMessage!));

                  final bins = _binsCache;
                  if (bins.isEmpty) return const Center(child: Text('No bins available'));

                  return ListView.builder(
                    itemCount: bins.length,
                    itemBuilder: (context, index) {
                      final item = bins[index];
                      final binId = _extractId(item);
                      final location = item['location'] ?? 'Unknown';
                      final type = item['type'] ?? 'Unknown';
                      int fillLevel = 0;
                      final rawFill = item['fill_level'] ?? item['fill_level_percent'] ?? 0;
                      if (rawFill is num) fillLevel = rawFill.round();
                      else if (rawFill is String) fillLevel = int.tryParse(rawFill) ?? 0;
                      final status = item['status'] ?? 'Unknown';

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
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBin(binId)),
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

const headerStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87);
