import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/case_history.dart';
import '../services/tracking_service.dart';
import 'case_history.dart'; // Reuse CaseDetailsPage if possible or create Rep version
import 'chat_provider_screen.dart';

class RepDashboard extends StatefulWidget {
  const RepDashboard({super.key});

  @override
  State<RepDashboard> createState() => _RepDashboardState();
}

class _RepDashboardState extends State<RepDashboard> {
  final TrackingService _trackingService = TrackingService();
  final CaseService _caseService = CaseService();
  final Color _themeOrange = const Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    // Check if web/large screen for responsive layout
    final bool isLargeScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Renel Ghana Staff Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _themeOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login_page'),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar for large screens
          if (isLargeScreen)
            Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSidebarItem(Icons.dashboard, 'Dashboard', true),
                  _buildSidebarItem(Icons.emergency, 'Active SOS', false),
                  _buildSidebarItem(Icons.history, 'Cases', false),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('© 2026 SilentGuard x Renel Ghana', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  )
                ],
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Summary Cards
                  LayoutBuilder(builder: (context, constraints) {
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        _buildSummaryCard('Active SOS', '3', Icons.emergency, Colors.red, constraints.maxWidth),
                        _buildSummaryCard('Pending Cases', '12', Icons.pending_actions, Colors.orange, constraints.maxWidth),
                        _buildSummaryCard('Resolved This Week', '24', Icons.check_circle, Colors.green, constraints.maxWidth),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 40),
                  
                  // Main Content Area (SOS & Cases)
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

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? _themeOrange : Colors.grey),
      title: Text(label, style: TextStyle(color: isSelected ? _themeOrange : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {},
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, double parentWidth) {
    double width = (parentWidth - 40) / 3;
    if (parentWidth < 600) width = parentWidth;
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActiveSOSList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active SOS Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tracking').where('status', isEqualTo: 'emergency').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text('No active SOS requests.');

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.emergency, color: Colors.white, size: 20)),
                    title: Text('SOS-ID: ${doc.id.substring(0,6)}'),
                    subtitle: Text('Status: ${data['status']}'),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/map_tracking', arguments: doc.id),
                      style: ElevatedButton.styleFrom(backgroundColor: _themeOrange),
                      child: const Text('Track', style: TextStyle(color: Colors.white)),
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

  Widget _buildRecentCasesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Incident Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StreamBuilder<List<CaseModel>>(
          stream: _caseService.getCasesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final cases = snapshot.data!;
            if (cases.isEmpty) return const Text('No incident reports found.');

            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cases.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final c = cases[index];
                  return ListTile(
                    title: Text(c.incidentNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c.victimName} • ${c.caseType}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusBadge(c.status),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailsPage(caseModel: c))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_outlined, color: Colors.green),
                          onPressed: () => Navigator.pushNamed(context, '/chat_provider', arguments: {
                            'uid': 'temp', // Logic to get victim UID
                            'name': c.victimName,
                          }),
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
    if (status.toLowerCase().contains('resolved')) color = Colors.green;
    if (status.toLowerCase().contains('progress')) color = Colors.blue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
