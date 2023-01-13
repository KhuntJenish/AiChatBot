import 'dart:async';

import 'package:aichatbot/threedot.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  ChatGPT? chatGPT;
  StreamSubscription? subscription;
  bool _isTyping = false;
  // mychatGptKey = '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';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  dispose() {
    super.dispose();
    subscription?.cancel();
  }

  void _handleSubmitted(String text) {
    final ChatMessage message = ChatMessage(
      text: text,
      sender: 'Me',
    );
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });
    _controller.clear();

    final request = CompleteReq(
      prompt: message.text,
      model: kCodeTranslateModelV2,
      max_tokens: 200,
    );

    subscription = chatGPT!.builder("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",orgId: "").onCompleteStream(request: request).listen((response) { 
      Vx.log(response!.choices[0].text);
      final ChatMessage message = ChatMessage(
        text: response.choices[0].text,
        sender: 'Bot',

      );
      setState(() {
        _isTyping = false;
        _messages.insert(0, message);
      });    
    });
  }

  _bulidTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration:
                const InputDecoration.collapsed(hintText: 'Send a message'),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _handleSubmitted(_controller.text);
            },
          ),
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat GPT'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            if (_isTyping)
              const ThreeDots(),
            const Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.cardColor,
              ),
              child: _bulidTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}
