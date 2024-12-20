import 'package:anonymous_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartChat extends StatefulWidget {
  const StartChat({super.key});

  @override
  State<StartChat> createState() => _StartChatState();
}

class _StartChatState extends State<StartChat> {
  // Supabase instance
  final supabase = Supabase.instance.client;

  // Current user ID
  String? currentUserId;

  // List of users
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    currentUserId = supabase.auth.currentUser?.id; // Get current user ID
    fetchUsers(); // Fetch users on initialization
  }

  // Fetch all users from the database
  Future<void> fetchUsers() async {
    try {
      final response = await supabase.from('users').select('*');

      if (response.isNotEmpty) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response);
        });
      } else {
        debugPrint('No users found.');
      }
    } catch (error) {
      debugPrint('Error fetching users: $error');
    }
  }

  // Create or retrieve a chat room between the current user and the selected user
  Future<int> getOrCreateChatRoom(String receiverId) async {
    try {
      // Check if a chat room already exists
      final existingRoom = await supabase
          .from('messages')
          .select('chat_room_id,sender_id,receiver_id')
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .or('sender_id.eq.$receiverId,receiver_id.eq.$receiverId');

      if (existingRoom.isNotEmpty) {
        // Return the existing chat room ID
        return existingRoom[0]['chat_room_id'];
      } else {
        // Create a new chat room
        final newRoom = await supabase
            .from('chat_rooms')
            .insert({
              'created_by': currentUserId,
            })
            .select('id')
            .single();

        print(newRoom['id']);

        return newRoom['id'];
      }
    } catch (error) {
      debugPrint('Error creating chat room: $error');
      throw Exception('Failed to create chat room.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Chat')),
      body: users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['username'] ?? 'Unknown User'),
                  subtitle: Text(user['email'] ?? 'No email provided'),
                  onTap: () async {
                    try {
                      // Get or create chat room
                      final chatRoomId =
                          await getOrCreateChatRoom(user['userid']);

                      // Navigate to ChatScreen with chat room ID and receiver ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatRoomId,
                            receiverId: user['userid'],
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error navigating to ChatScreen: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to start chat.')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
