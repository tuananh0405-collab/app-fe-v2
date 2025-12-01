import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../flutter_flow/flutter_flow.dart';
import '../domain/gps_scan_record.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  List<GpsScanRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      if (!Hive.isBoxOpen('gps_history')) {
        await Hive.initFlutter();
        await Hive.openBox('gps_history');
      }
      final box = Hive.box('gps_history');
      final list = <GpsScanRecord>[];
      for (int i = 0; i < box.length; i++) {
        final raw = box.getAt(i) as Map<dynamic, dynamic>;
        list.add(GpsScanRecord.fromJson(raw));
      }
      setState(() {
        _records = list.reversed.toList(); // newest first
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _records = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location History'),
        backgroundColor: theme.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('No location history available', style: theme.bodyText1),
                      )
                    ],
                  )
                : ListView.separated(
                    itemCount: _records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = _records[index];
                      return ListTile(
                        leading: Icon(
                          r.success ? Icons.check_circle_outline : Icons.error_outline,
                          color: r.success ? theme.success : theme.error,
                        ),
                        title: Text(
                          r.success ? 'Scan success' : 'Scan failed',
                          style: theme.title3,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (r.latitude != null && r.longitude != null)
                              Text('Lat: ${r.latitude}, Lon: ${r.longitude}'),
                            if (r.accuracy != null) Text('Accuracy: ${r.accuracy} m'),
                            if (r.error != null) Text('Error: ${r.error}'),
                            if (r.statusCode != null) Text('Status: ${r.statusCode}'),
                          ],
                        ),
                        trailing: Text(
                          _formatTime(r.timestamp),
                          style: theme.bodyText2,
                        ),
                        onTap: () => _showDetails(r),
                      );
                    },
                  ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    return '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  void _showDetails(GpsScanRecord r) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(r.success ? 'Scan details' : 'Scan failed'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time: ${_formatTime(r.timestamp)}'),
              if (r.latitude != null && r.longitude != null) Text('Lat: ${r.latitude}'),
              if (r.longitude != null) Text('Lon: ${r.longitude}'),
              if (r.accuracy != null) Text('Accuracy: ${r.accuracy} m'),
              if (r.statusCode != null) Text('Status code: ${r.statusCode}'),
              if (r.error != null) ...[
                const SizedBox(height: 8),
                Text('Error: ${r.error}'),
              ],
              if (r.responseData != null) ...[
                const SizedBox(height: 8),
                Text('Response: ${r.responseData}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Close'))
        ],
      ),
    );
  }
}
