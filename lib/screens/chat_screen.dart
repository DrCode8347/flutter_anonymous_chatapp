import 'package:anonymous_chat/utils/queries.dart';
import 'package:flutter/material.dart';
import 'package:openpgp/openpgp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final String? receiverId;

  ChatScreen({super.key, required this.chatId, this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  String? userId;
  String? replyMessage;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = _supabase.auth.currentUser?.id;
    print(widget.receiverId);
  }

  void handleReply(String message) {
    setState(() {
      replyMessage = message;
    });
  }

  void clearReply() {
    setState(() {
      replyMessage = null;
    });
  }

  Future<void> sendMessage(String content, [String? userId]) async {
    try {
      String? receiverId = widget.receiverId;

      if (receiverId == null || receiverId.isEmpty) {
        final getReceiverID = await _supabase
            .from('messages')
            .select('receiver_id')
            .eq('chat_room_id', widget.chatId)
            .limit(1)
            .maybeSingle();

        receiverId = getReceiverID?['receiver_id'];
        if (receiverId == null) {
          throw Exception(
              'Receiver ID not found for chat room ${widget.chatId}');
        }
      }

      final publicKeyResult = await _supabase
          .from('users')
          .select('publickey')
          .eq('userid', receiverId)
          .maybeSingle();

      final publicKey = publicKeyResult?['publickey'];
      if (publicKey == null) {
        throw Exception('Public key not found for user $receiverId');
      }

      final encryptedMessage = await OpenPGP.encrypt(content, publicKey);

      await _supabase.from('messages').insert({
        'sender_id': userId,
        'content': encryptedMessage,
        'receiver_id': receiverId,
        'chat_room_id': widget.chatId,
        'created_at': DateTime.now().toIso8601String(),
      });

      messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat ${widget.chatId}"),
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id']).eq('chat_room_id', widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message["sender_id"] == userId;
                    final status = message["status"] ?? '0';
                    final time = message["created_at"];

                    return FutureBuilder<String>(
                      future: decryptMessage(
                          _supabase, userId!, message["content"]),
                      builder: (context, snapshot) {
                        final decryptedMessage =
                            snapshot.data ?? 'Decrypting...';

                        return Dismissible(
                          key: ValueKey(message["id"]),
                          direction: isSender
                              ? DismissDirection.endToStart
                              : DismissDirection.startToEnd,
                          onUpdate: (details) {
                            if (details.reached &&
                                replyMessage != message["content"]) {
                              handleReply(message["content"]);
                            }
                          },
                          confirmDismiss: (_) async => false,
                          background: Container(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.transparent,
                            child: Icon(
                              Icons.reply,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 24,
                            ),
                          ),
                          child: Align(
                            alignment: isSender
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(8),
                                  topRight: const Radius.circular(8),
                                  bottomLeft: isSender
                                      ? const Radius.circular(8)
                                      : Radius.zero,
                                  bottomRight: isSender
                                      ? Radius.zero
                                      : const Radius.circular(8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    decryptedMessage,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (isSender)
                                        Icon(
                                          status == 0
                                              ? Icons.check
                                              : status == 1
                                                  ? Icons.done_all
                                                  : Icons.done_all,
                                          size: 16,
                                          color: status == 2
                                              ? Colors.blue
                                              : Colors.white70,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Reply Indicator
          if (replyMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Replying to: $replyMessage",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: clearReply,
                  ),
                ],
              ),
            ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sendMessage(messageController.text, userId!);
                    clearReply();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
