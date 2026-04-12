import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tracking_service.dart';

/// Admin view: watches a specific SOS request document in Firestore
/// and renders the USER's live location on the map — NOT the admin's GPS.
class AdminMapTrackingScreen extends StatefulWidget {
  final String requestId;
  const AdminMapTrackingScreen({super.key, required this.requestId});

  @override
  State<AdminMapTrackingScreen> createState() => _AdminMapTrackingScreenState();
}

class _AdminMapTrackingScreenState extends State<AdminMapTrackingScreen> {
  static const Color _bronze = Color(0xFFCD7F32);
  final TrackingService _trackingService = TrackingService();
  final MapController _mapController = MapController();

  LatLng? _userLatLng;
  LatLng? _helperLatLng;
  String _status = 'emergency';
  StreamSubscription<DocumentSnapshot>? _requestSub;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _listenToTracking();
  }

  void _listenToTracking() {
    _requestSub = _trackingService
        .getRequestStream(widget.requestId)
        .listen((doc) {
      if (!doc.exists || !mounted) return;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;

      final userPos = data['user'] as Map<String, dynamic>?;
      setState(() {
        _status = data['status'] ?? 'emergency';
        if (userPos != null) {
          final lat = (userPos['lat'] as num?)?.toDouble();
          final lng = (userPos['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            _userLatLng = LatLng(lat, lng);
            _mapController.move(_userLatLng!, 15.0);
          }
        }

        final helperPos = data['helper'] as Map<String, dynamic>?;
        if (helperPos != null) {
          final hLat = (helperPos['lat'] as num?)?.toDouble();
          final hLng = (helperPos['lng'] as num?)?.toDouble();
          if (hLat != null && hLng != null) {
            _helperLatLng = LatLng(hLat, hLng);
          }
        } else {
          _helperLatLng = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus, {String? eta}) async {
    setState(() => _isUpdating = true);
    final updates = <String, dynamic>{'status': newStatus};
    if (eta != null) updates['eta'] = eta;
    await FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.requestId)
        .update(updates);
    setState(() => _isUpdating = false);
  }

  Future<void> _assignHelper() async {
    setState(() => _isUpdating = true);
    // Simulate assigning an admin as the helper (uses a fixed offset from user)
    final helperLat = (_userLatLng?.latitude ?? 5.6037) + 0.005;
    final helperLng = (_userLatLng?.longitude ?? -0.1870) + 0.005;
    await FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.requestId)
        .update({
      'status': 'help_on_the_way',
      'helper': {'lat': helperLat, 'lng': helperLng},
      'eta': 'Help is on the way',
    });
    setState(() => _isUpdating = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Response dispatched to user')),
      );
    }
  }

  void _showResolveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve SOS'),
        content: const Text(
            'Mark this SOS as resolved? The user will be notified.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateStatus('resolved', eta: 'Help has arrived');
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Resolve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == 'emergency') return Colors.red;
    if (status == 'help_on_the_way') return Colors.orange;
    if (status == 'resolved') return Colors.green;
    if (status == 'cancelled') return Colors.grey;
    return Colors.blueGrey;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'emergency':
        return '🚨 ACTIVE SOS';
      case 'help_on_the_way':
        return '🚓 Response Dispatched';
      case 'resolved':
        return '✅ Resolved';
      case 'cancelled':
        return '🚫 Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _bronze,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live SOS Tracking',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('ID: ${widget.requestId.substring(0, 8)}...',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(_status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(_status),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Area — shows USER's live location
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLatLng ?? const LatLng(5.6037, -0.1870),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.silent_guard',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_userLatLng != null)
                          Marker(
                            point: _userLatLng!,
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('USER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                                const Icon(Icons.person_pin_circle, color: Colors.red, size: 36),
                              ],
                            ),
                          ),
                        if (_helperLatLng != null)
                          Marker(
                            point: _helperLatLng!,
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('HELPER', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                                const Icon(Icons.directions_car, color: Colors.blue, size: 36),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_userLatLng == null)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Waiting for user location...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Location badge
                if (_userLatLng != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'User: ${_userLatLng!.latitude.toStringAsFixed(5)}, ${_userLatLng!.longitude.toStringAsFixed(5)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Admin Controls',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    if (_isUpdating)
                      const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)))
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          // Dispatch Response
                          if (_status == 'emergency')
                            ElevatedButton.icon(
                              onPressed: _assignHelper,
                              icon: const Icon(Icons.directions_car, size: 16),
                              label: const Text('Dispatch Response'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
    
                          // Resolve
                          if (_status != 'resolved' && _status != 'cancelled')
                            ElevatedButton.icon(
                              onPressed: _showResolveDialog,
                              icon: const Icon(Icons.check_circle, size: 16),
                              label: const Text('Mark Resolved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
    
                          // Cancel SOS
                          if (_status != 'resolved' && _status != 'cancelled')
                            OutlinedButton.icon(
                              onPressed: () async {
                                await _updateStatus('cancelled');
                                if (mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                              label: const Text('Cancel SOS', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
