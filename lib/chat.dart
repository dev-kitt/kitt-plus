import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'model.dart';
import 'package:kitt_plus/env/env.dart';
//import 'package:http/http.dart' as http;
import 'package:kitt_plus/theme.dart';
import 'package:kitt_plus/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future generateResponse(String prompt) async {
  final apiKey = Env.googleAiApiKey;
  final generationConfig = GenerationConfig(
    stopSequences: ["red"],
    maxOutputTokens: 200,
    temperature: 0.9,
    topP: 0.1,
    topK: 16,
  );
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
    generationConfig: generationConfig,
  );
  final response = await model.generateContent([Content.text(prompt)]);
  // Extracting the text from the GenerateContentResponse object
  return response.text;
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;
  bool isFavorite = false;
  String paste = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    isLoading = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SpeechToText speechToText = SpeechToText();
  bool click = true;
  var isListening = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          drawer: const NavDrawer(),
          appBar: AppBar(
            backgroundColor:
                (click == false) ? AppColors.textDark : AppColors.secondary,
            shadowColor: AppColors.accent,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/kitt_header.png',
                  fit: BoxFit.contain,
                  height: 38,
                ),
              ],
            ),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: GestureDetector(
                      onTap: () {
                        isFavorite = !isFavorite;
                        setState(() {
                          click = !click;
                        });
                      },
                      child: isFavorite
                          ? Image.asset(
                              'assets/kitt_plus_dark.png',
                              fit: BoxFit.contain,
                              height: 38,
                            )
                          : Image.asset(
                              'assets/kitt_plus.png',
                              fit: BoxFit.contain,
                              height: 38,
                            ))),
              PopupMenuButton(
                  // add icon, by default "3 dot" icon
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Refresh"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("About"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage()),
                      ).then((value) => setState(() {}));
                    } else if (value == 1) {
                      showAboutDialog(
                          context: context,
                          applicationName: 'Kitt.Plus GoogleAI',
                          applicationVersion: '0.1.1',
                          applicationIcon: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(18), // Image border
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(28), // Image radius
                              child: Image.asset(
                                'assets/logo_foreground.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          children: <Widget>[
                            const Text(
                                'Flutter Chatbot App built with Gemini Pro'),
                            const Text('Developed by Kitt, LLC ©🐿️ 2019-2024'),
                          ]);
                    }
                  }),
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
                      height: 18,
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
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AvatarGlow(
                glowRadiusFactor: 0.8,
                glowShape: BoxShape.circle,
                animate: true,
                duration: const Duration(milliseconds: 2000),
                glowColor: AppColors.secondary,
                repeat: true,
                startDelay: const Duration(milliseconds: 100),
                glowCount: 2,
                child: GestureDetector(
                  onTapDown: (details) async {
                    if (!isListening) {
                      var available = await speechToText.initialize();
                      if (available) {
                        setState(() {
                          isListening = true;
                          speechToText.listen(
                            onResult: (result) {
                              setState(() {
                                _textController.text = result.recognizedWords;
                              });
                            },
                          );
                        });
                      }
                    }
                  },
                  onTapUp: (details) {
                    setState(() {
                      isListening = false;
                    });
                    speechToText.stop();
                  },
                  child: const Icon(
                    Icons.mic_rounded,
                  ),
                ),
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
                  hintText: 'Tap to talk or type your request:',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: GlowingActionButton(
              color: (click == false) ? AppColors.neon : AppColors.secondary,
              icon: CupertinoIcons.hare_fill,
              onPressed: () async {
                // display user input
                if (_textController.text.isNotEmpty) {
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid request"),
                    ),
                  );
                }
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
      _scrollController.position.extentAfter,
      duration: const Duration(milliseconds: 100),
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
      padding: const EdgeInsets.all(18),
      color: chatMessageType == ChatMessageType.bot
          ? AppColors.textDark
          : AppColors.cardDark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 18.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      'assets/bot.png',
                      scale: 0.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 18.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
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
                  padding: const EdgeInsets.all(12.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  ),
                  child: text.contains("generativelanguage")
                      ? Column(
                          children: [
                            Container(
                                alignment: Alignment.center,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox.fromSize(
                                    child:
                                        Image.network(text, fit: BoxFit.cover),
                                  ),
                                )),
                          ],
                        )
                      : SelectableText(
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
