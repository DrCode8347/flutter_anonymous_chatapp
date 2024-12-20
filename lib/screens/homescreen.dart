import 'package:anonymous_chat/screens/chat_screen.dart';
import 'package:anonymous_chat/screens/start_chat.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // User ID for the logged-in user
  String? userId;

  @override
  void initState() {
    super.initState();
    // Get the user ID from authentication state
    userId = _supabase.auth.currentUser?.id;
  }

  fetchChatroom() async {
    final response = _supabase
        .from('chat_rooms')
        .select('''
        id,
        name,
        is_group,
        created_by,
        created_at,
        updated_at,
        messages!inner (
          chat_room_id,
          sender_id,
          receiver_id
        )
      ''')
        .or('receiver_id.eq.$userId,sender_id.eq.$userId',
            referencedTable: 'messages')
        .order('created_at', ascending: false)
        .asStream();
    return response;
  }

  Stream<dynamic> _refreshData() {
    return fetchChatroom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anochat"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: userId == null
          ? Center(
              child: Text(
                "No user logged in",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : StreamBuilder(
              stream: fetchChatroom(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Handle errors
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                // Handle empty data
                if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/splashIcon.png',
                          width: 250,
                        ),
                        Text('No chats available')
                      ],
                    ),
                  );
                }

                // Display chat rooms
                final chatRooms = snapshot.data as List<dynamic>;

                return RefreshIndicator(
                  onRefresh: fetchChatroom(), // Trigger the refresh function
                  child: ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final chat = chatRooms[index];

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                radius: 25,
                                child: Text(
                                  chat['name']?.substring(0, 1) ??
                                      "A", // First letter of chat name
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: chat['is_group'] == true
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            chat['name'] ?? "Chat ${index + 1}",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          subtitle: Text(
                            chat['is_group'] == true
                                ? "Group Chat"
                                : "One-to-One Chat",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chat['created_at'] != null
                                    ? _formatDate(chat['created_at'])
                                    : "N/A",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat['id'],
                                  receiverId: '', // Replace as needed
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create group or new chat screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => StartChat()),
          );
        },
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }

  // Helper function to format date
  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return "${date.day}/${date.month}/${date.year}";
  }
}