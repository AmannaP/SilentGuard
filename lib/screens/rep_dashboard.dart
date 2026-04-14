import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/case_history.dart';
import 'admin_map_tracking_screen.dart';
import 'admin_case_detail_screen.dart';
import 'admin_messages_screen.dart';

class RepDashboard extends StatefulWidget {
  const RepDashboard({super.key});

  @override
  State<RepDashboard> createState() => _RepDashboardState();
}

class _RepDashboardState extends State<RepDashboard> {
  final CaseService _caseService = CaseService();
  final AuthService _authService = AuthService();
  static const Color _bronze = Color(0xFFCD7F32);

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _bronze),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Renel Ghana Staff Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bronze,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMessagesScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar for large screens
          if (isLargeScreen)
            Container(
              width: 230,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSidebarItem(Icons.dashboard, 'Dashboard', true),
                  _buildSidebarItem(Icons.emergency, 'Active SOS', false),
                  _buildSidebarItem(Icons.history, 'Cases', false),
                  _buildSidebarItem(Icons.message, 'Messages', false, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMessagesScreen()));
                  }),
                  _buildSidebarItem(Icons.feedback_outlined, 'Feedback', false, onTap: () {
                    Navigator.pushNamed(context, '/admin_feedback');
                  }),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '© 2026 SilentGuard × Renel Ghana',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // ── Summary Cards (live from Firestore) ──
                  _LiveStatsRow(),

                  const SizedBox(height: 36),

                  // ── Main dual-pane layout ──
                  if (isLargeScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: _buildActiveSOSList()),
                        const SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildRecentCasesList()),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildActiveSOSList(),
                        const SizedBox(height: 24),
                        _buildRecentCasesList(),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? _bronze : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? _bronze : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {},
    );
  }

  // ── Active SOS List ──
  Widget _buildActiveSOSList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Active SOS Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tracking')
              .where('status', whereIn: ['emergency', 'help_on_the_way'])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)));
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 10),
                    Text('No active SOS requests', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final userPos = data['user'] as Map<String, dynamic>?;
                final lat = (userPos?['lat'] as num?)?.toStringAsFixed(4) ?? '—';
                final lng = (userPos?['lng'] as num?)?.toStringAsFixed(4) ?? '—';
                final victimName = data['userName'] ?? 'Unknown User';
                final displayTime = data['displayDate'] ?? 'Date unknown';
                final status = data['status'] ?? 'emergency';
                final isDispatched = status == 'help_on_the_way';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  color: isDispatched ? Colors.orange.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isDispatched ? Colors.orange : Colors.red,
                              radius: 16,
                              child: Icon(
                                isDispatched ? Icons.directions_car : Icons.emergency, 
                                color: Colors.white, 
                                size: 16
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(victimName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('Alerted at: $displayTime',
                                      style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDispatched ? Colors.orange : Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isDispatched ? 'DISPATCHED' : 'URGENT',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text('Location: $lat, $lng',
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                             const SizedBox(height: 10),
                             SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminMapTrackingScreen(requestId: doc.id),
                                  ),
                                ),
                                icon: const Icon(Icons.map_outlined, size: 16),
                                label: Text(isDispatched ? 'Continue Tracking' : 'Track User Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDispatched ? Colors.orange : _bronze,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ── Recent Cases List ──
  Widget _buildRecentCasesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Incident Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<List<CaseModel>>(
          stream: _caseService.getCasesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)));
            }
            final cases = snapshot.data!;
            if (cases.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No incident reports found.',
                    style: TextStyle(color: Colors.grey)),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cases.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final c = cases[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: _bronze.withOpacity(0.1),
                      child: Icon(Icons.folder_outlined, color: _bronze, size: 20),
                    ),
                    title: Text(c.incidentNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      '${c.victimName} • ${c.caseType}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusBadge(c.status),
                        const SizedBox(width: 6),
                        // Navigate to ADMIN case detail, not CaseDetailsPage (user view)
                        IconButton(
                          icon: const Icon(Icons.edit_note_outlined, color: Color(0xFFCD7F32)),
                          tooltip: 'Manage Case',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminCaseDetailScreen(caseModel: c),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status.toLowerCase().contains('resolved') || status.toLowerCase().contains('closed')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('progress')) {
      color = Colors.blue;
    } else if (status.toLowerCase() == 'open') {
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Live Stats Row ──
class _LiveStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _LiveStatCard(
              label: 'Active SOS',
              icon: Icons.emergency,
              color: Colors.red,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
              query: FirebaseFirestore.instance
                  .collection('tracking')
                  .where('status', isEqualTo: 'emergency'),
            ),
            _LiveStatCard(
              label: 'Open Cases',
              icon: Icons.pending_actions,
              color: Colors.orange,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
              query: FirebaseFirestore.instance
                  .collection('cases')
                  .where('status', isEqualTo: 'Open'),
            ),
            _LiveStatCard(
              label: 'Resolved Cases',
              icon: Icons.check_circle,
              color: Colors.green,
              width: isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3,
              query: FirebaseFirestore.instance
                  .collection('cases')
                  .where('status', isEqualTo: 'Resolved'),
            ),
          ],
        );
      },
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final Query query;

  const _LiveStatCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                snapshot.connectionState == ConnectionState.waiting ? '...' : '$count',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
