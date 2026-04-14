import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/feedback_service.dart';
import '../services/auth_service.dart';
import '../utils/ui_utils.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  
  String _selectedType = 'Support';
  bool _isLoading = false;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      
      final userDataDoc = await AuthService().getUserData(user.uid);
      final userData = userDataDoc.data() as Map<String, dynamic>?;
      
      final feedback = FeedbackModel(
        userId: user.uid,
        userName: userData?['fullName'] ?? user.displayName ?? 'Unknown User',
        userEmail: userData?['email'] ?? user.email ?? 'No Email',
        message: _messageController.text.trim(),
        type: _selectedType,
        timestamp: DateTime.now(),
      );

      await _feedbackService.submitFeedback(feedback);
      
      if (mounted) {
        UIUtils.showCustomPopup(
          context,
          title: 'Feedback Sent',
          message: 'Thank you! You can track this request in the "My Tickets" tab.',
          isSuccess: true,
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showCustomPopup(context, title: 'Error', message: 'Could not send feedback: $e', isSuccess: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bronze = Color(0xFFCD7F32);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Help & Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: bronze,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'New Request'),
              Tab(text: 'My Tickets'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildSubmitTab(bronze),
            _buildHistoryTab(bronze),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitTab(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('How can we help?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Submit a request and our team will get back to you shortly.', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildFormFields(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Request Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          items: ['Support', 'Bug Report', 'Feature Request', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Describe your issue...', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Please enter a message' : null,
        ),
      ],
    );
  }

  Widget _buildHistoryTab(Color themeColor) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please log in to see your tickets.'));

    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getMyFeedbacksStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return const Center(child: Text('You haven\'t submitted any requests yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = tickets[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
              child: ExpansionTile(
                title: Text(t.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(t.timestamp.toString().split(' ')[0], style: const TextStyle(fontSize: 12)),
                trailing: _buildStatusChip(t.status),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Message:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(t.message),
                        if (t.adminReply != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Staff Reply:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                                const SizedBox(height: 4),
                                Text(t.adminReply!, style: const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(FeedbackStatus status) {
    Color color;
    switch (status) {
      case FeedbackStatus.open: color = Colors.red; break;
      case FeedbackStatus.inProgress: color = Colors.orange; break;
      case FeedbackStatus.resolved: color = Colors.green; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
