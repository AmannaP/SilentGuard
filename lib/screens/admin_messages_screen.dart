import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_provider_screen.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Active Chats',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query the root 'chats' collection for documents where 'renel_ghana_default' is a participant
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: 'renel_ghana_default')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs.toList() ?? [];
          
          // Sort in memory to avoid needing a composite index
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final tsA = dataA['lastMessageTime'] as Timestamp?;
            final tsB = dataB['lastMessageTime'] as Timestamp?;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No active conversations yet.',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Extract chat metadata
              final String lastMsg = data['lastMessage'] ?? 'Attachment';
              final Timestamp? timestamp = data['lastMessageTime'] as Timestamp?;
              final String timeStr = timestamp != null 
                  ? timeago.format(timestamp.toDate()) 
                  : '';
              final String userId = data['userId'] ?? 'unknown';

              return FutureBuilder<DocumentSnapshot>(
                // Load the standard user's details for display
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnap) {
                  String userName = 'Loading...';
                  if (userSnap.hasData && userSnap.data!.exists) {
                    final userData = userSnap.data!.data() as Map<String, dynamic>;
                    userName = userData['fullName'] ?? 'Unknown Victim';
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFCD7F32).withOpacity(0.2),
                      child: const Icon(Icons.person, color: Color(0xFFCD7F32)),
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    trailing: Text(
                      timeStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () {
                      // Navigate inside the chat exactly how a provider screen expects
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatProviderScreen(
                            providerData: {
                              'uid': userId, // The admin talks TO the user
                              'name': userName,
                              'isAdmin': true,
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
