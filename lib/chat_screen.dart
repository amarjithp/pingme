import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('messages').add({
      'text': messageController.text.trim(),
      'sender': user!.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat (${user!.email})'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender'] == user!.email;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text("${msg['sender']}: ${msg['text']}"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: 'Enter message...',
                  ),
                ),
              ),
              IconButton(onPressed: sendMessage, icon: Icon(Icons.send)),
            ],
          ),
        ],
      ),
    );
  }
}
