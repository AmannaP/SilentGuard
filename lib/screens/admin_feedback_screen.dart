import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final FeedbackService _service = FeedbackService();
  static const Color _bronze = Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Feedback Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: _bronze,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Open Tickets'),
              Tab(text: 'History'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedbackList(isOpenOnly: true),
            _buildFeedbackList(isOpenOnly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList({required bool isOpenOnly}) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: _service.getFeedbacksStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: _bronze));
        }
        
        final allFeedbacks = snapshot.data!;
        final filteredFeedbacks = allFeedbacks.where((f) {
          if (isOpenOnly) {
            return f.status != FeedbackStatus.resolved;
          } else {
            return f.status == FeedbackStatus.resolved;
          }
        }).toList();

        if (filteredFeedbacks.isEmpty) {
          return Center(
            child: Text(
              isOpenOnly ? 'No active tickets.' : 'No resolved tickets in history.',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredFeedbacks.length,
          itemBuilder: (context, index) {
            final f = filteredFeedbacks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(f.status).withOpacity(0.12),
                  child: Icon(Icons.feedback_outlined, color: _getStatusColor(f.status)),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                    _buildStatusLabel(f.status),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      f.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text('By ${f.userName} • ${f.timestamp.toString().split(' ')[0]}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
                onTap: () => _showFeedbackDetail(f),
              ),
            );
          },
        );
      },
    );
  }

  void _showFeedbackDetail(FeedbackModel feedback) {
    final replyController = TextEditingController(text: feedback.adminReply);
    FeedbackStatus currentStatus = feedback.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('Manage Support Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('User', feedback.userName),
                      _buildInfoRow('Email', feedback.userEmail),
                      _buildInfoRow('Request Type', feedback.type),
                      _buildInfoRow('Date Submitted', feedback.timestamp.toString().split('.')[0]),
                      const SizedBox(height: 24),
                      const Text('User Message:', style: TextStyle(fontWeight: FontWeight.bold, color: _bronze)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                        child: Text(feedback.message, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text('Resolution Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      const Text('Set Current Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: FeedbackStatus.values.map((s) => ChoiceChip(
                          label: Text(s.name.toUpperCase()),
                          selected: currentStatus == s,
                          onSelected: (val) => setModalState(() => currentStatus = s),
                          selectedColor: _bronze,
                          labelStyle: TextStyle(color: currentStatus == s ? Colors.white : Colors.black87),
                        )).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('Official Staff Reply', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: replyController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type your reply to the victim here...',
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _service.updateFeedback(
                              feedback.id!,
                              status: currentStatus,
                              adminReply: replyController.text.trim(),
                            );
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _bronze,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Update & Sync Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.open: return Colors.red;
      case FeedbackStatus.inProgress: return Colors.orange;
      case FeedbackStatus.resolved: return Colors.green;
    }
  }

  Widget _buildStatusLabel(FeedbackStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
