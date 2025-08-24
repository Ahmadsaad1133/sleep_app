import 'package:flutter/material.dart';
import '../services/api/api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Each message is represented by a map with keys 'sender' and 'message'.
  /// 'sender' can be 'user' or 'ai'.
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _addDefaultGreeting();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// When the page first loads, call the backend with an empty prompt.
  /// The Flask endpoint will return the default greeting text.
  Future<void> _addDefaultGreeting() async {
    try {
      final greeting = await ApiService.generateResponse("");
      setState(() {
        _messages.add({'sender': 'ai', 'message': greeting});
      });
      _scrollToBottom();
    } catch (e) {
      // If there's an error fetching the greeting, you can choose to log it
      // or add a fallback message. For now, just print to console.
      debugPrint("Error fetching default greeting: $e");
    }
  }

  Future<void> _sendPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      // 1) Add the user's message
      _messages.add({'sender': 'user', 'message': prompt});
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // 2) Send the prompt to the backend and await AI response
      final response = await ApiService.generateResponse(prompt);
      setState(() {
        _messages.add({'sender': 'ai', 'message': response});
      });
      // small delay so that the new message is laid out before scrolling
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'ai', 'message': 'Error: $e'});
      });
      _scrollToBottom();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final bool isUser = message['sender'] == 'user';
    final bgColor = isUser ? Colors.blueAccent.shade400 : Colors.grey.shade300;
    final textColor = isUser ? Colors.white : Colors.black87;
    final radius = isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomRight: Radius.circular(18),
    );

    final avatar = isUser
        ? CircleAvatar(
      radius: 16,
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.person, color: Colors.white, size: 18),
    )
        : CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade700,
      child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) avatar,
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                message['message'] ?? '',
                style: TextStyle(
                  fontFamily: 'AirbnbCereal',
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) avatar,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a full-screen background image instead of the gradient
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chat_ai_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar over the image
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble_outline,
                        color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Silent Moon AI Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'AirbnbCereal',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded ListView: shows all messages (including default greeting)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),

              // If loading, show a thin progress bar
              if (_loading)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  minHeight: 3,
                ),

              // Input area with rounded style and shadow
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) =>
                        _loading ? null : _sendPrompt(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            fontFamily: 'AirbnbCereal',
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.white.withOpacity(0.3),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        color: Colors.white,
                        onPressed: _loading ? null : _sendPrompt,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
