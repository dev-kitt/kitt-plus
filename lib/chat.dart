import 'dart:async';
import 'dart:convert';
import 'model.dart';
import 'package:kitt_plus/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:kitt_plus/theme.dart';
import 'package:kitt_plus/widgets/glowing_action_button.dart';
import 'package:kitt_plus/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future<String> generateResponse(String prompt) async {
  final apiKey = Env.openAiApiKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  String utf8Body = utf8.decode(response.bodyBytes);

  // Decode the JSON string
  Map<String, dynamic> newresponse = jsonDecode(utf8Body);

  return newresponse['choices'][0]['text'];
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;
  String paste = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isLoading = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: const NavDrawer(),
          appBar: AppBar(
            backgroundColor: AppColors.secondary,
            shadowColor: AppColors.accent,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/kitt_plus.png',
                  fit: BoxFit.contain,
                  height: 42,
                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      CupertinoIcons.moon_zzz_fill,
                      size: 26.0,
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.more_vert),
                  )),
            ],
          ),
          backgroundColor: AppColors.cardDark,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildList(),
                ),
                Visibility(
                  visible: isLoading,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildInput(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Material(
            color: AppColors.cardDark,
            elevation: 16,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: TabBar(
                indicatorColor: AppColors.secondary,
                indicatorWeight: 5,
                tabs: <Tab>[
                  Tab(
                    icon: Image.asset(
                      'assets/made_footer.png',
                      fit: BoxFit.contain,
                      height: 33,
                    ),
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ),
        ));
  }

  Expanded _buildInput() {
    return Expanded(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                CupertinoIcons.rocket_fill,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Make a request or ask a question...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 24.0,
            ),
            child: GlowingActionButton(
              color: AppColors.secondary,
              icon: Icons.send_rounded,
              onPressed: () async {
                // display user input
                setState(
                  () {
                    _messages.add(
                      ChatMessage(
                        text: _textController.text,
                        chatMessageType: ChatMessageType.user,
                      ),
                    );
                    isLoading = true;
                  },
                );
                var input = _textController.text;
                _textController.clear();
                Future.delayed(const Duration(milliseconds: 50))
                    .then((_) => _scrollDown());

                // call chatbot api
                generateResponse(input).then((value) {
                  setState(() {
                    isLoading = false;
                    // display chatbot response
                    _messages.add(
                      ChatMessage(
                        text: value,
                        chatMessageType: ChatMessageType.bot,
                      ),
                    );
                  });
                });
                _textController.clear();
                Future.delayed(const Duration(milliseconds: 50))
                    .then((_) => _scrollDown());
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? AppColors.textDark
          : AppColors.cardDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(136, 85, 255, 1),
                    child: Image.asset(
                      'assets/bot.png',
                      scale: 0.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
                    child: Image.asset(
                      'assets/kitt_bot.png',
                      scale: 0.5,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
