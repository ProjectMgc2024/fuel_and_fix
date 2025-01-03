import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:developer';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  AiChatPageState createState() => AiChatPageState();
}

class AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  List<Map<String, dynamic>>? usersPosts;

  @override
  void initState() {
    super.initState();
  }

  final instructions = '''
"instruction"={"system_prompt"  : "Your name is Fix AI. your aim is to assist the user for the user_input . this is the system instruction and i provide app details in app_details. you can understand the app details from there. you must give reply to the user_input." , "app_details": "The Fuel Filling and Emergency Repair Management System for Vehicles is designed to enhance
vehicle service accessibility by streamlining the process of fuel delivery, emergency repairs, and tow
services. This system provides a centralized platform for vehicle owners to request fuel refills,
emergency repair services, or tow services whenever needed. By leveraging GPS tracking, the
system identifies the exact location of stranded vehicles and connects drivers with nearby service
providers.
Key features include a user-friendly interface for placing service requests, secure payment
processing, and feedback mechanisms to ensure service quality. This project utilizes a database to
manage service requests, store provider information, and record transaction history, ensuring
efficient and transparent management of services.
This system is intended to increase convenience, reduce downtime, and improve safety for vehicle
owners by offering an effective solution for fuel shortages or unexpected breakdowns. The
application's flexibility allows it to be adapted for various types of vehicles, from personal cars to
commercial fleets, making it a scalable solution in the realm of vehicle assistance services.
Detailed Functionalities
1. **Service Request Platform**: Users can request fuel delivery, emergency repairs, or tow services
through a simple, user-friendly interface.
2. **GPS Location Tracking**: The system fetches the user's current location to ensure accurate and
timely delivery of services.
3. **Database Management**: A robust database manages service requests, stores provider
information, and records transaction history to ensure seamless operations.
4. **Secure Payment Processing**: Integrated secure payment gateways allow users to pay for
services directly through the platform.
5. **Feedback Mechanism**: Users can provide ratings and feedback for services received, helping
to maintain service quality and reliability.
6. **Flexibility for Various Vehicles**: The system is designed to accommodate different types of
vehicles, including personal cars and commercial fleets, ensuring scalability and adaptability"}''';

  void _sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': userMessage});
      _isLoading = true;
    });

    String modifiedUserInput =
        '''$instructions,  "user_input": "$userMessage"''';

    try {
      final gemini = Gemini.instance;

      final conversation = [
        ..._chatHistory.map(
          (msg) => Content(
            parts: [Part.text(msg['message']!)],
            role: msg['role'],
          ),
        ),
        Content(
          parts: [Part.text(modifiedUserInput)],
          role: 'user',
        ),
      ];
      final response = await gemini.chat(conversation);
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'model',
            'message': response?.output ?? 'No response received',
          });
        });
      }
    } catch (e) {
      log('Error in chat: $e');
      if (mounted) {
        setState(() {
          _chatHistory.add({
            'role': 'error',
            'message':
                'Response not loading. Please try again or check your internet connection.',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessageBubble(String message, String role,
      {bool isLoading = false}) {
    bool isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: isUser ? const Radius.circular(20.0) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 39, 36, 36).withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
                message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: isUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        if (index == _chatHistory.length && _isLoading) {
          return _buildMessageBubble('', 'model', isLoading: true);
        }
        final message = _chatHistory[index];
        return _buildMessageBubble(message['message']!, message['role']!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('asset/pic01.jpg'),
                backgroundColor: Colors.blue,
                radius: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Fix Ai',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _chatHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Start a conversation with Explore Ai',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 43, 40, 40)),
                      ),
                    )
                  : _buildChatList(),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        minLines: 1,
                        maxLines: 5,
                        onSubmitted: (_) {
                          final message = _controller.text;
                          _controller.clear();
                          _sendMessage(message);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        final message = _controller.text;
                        _controller.clear();
                        _sendMessage(message);
                      },
                      splashColor: Colors.blueAccent.withOpacity(0.3),
                      splashRadius: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
