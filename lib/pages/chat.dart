import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
import 'package:kitt_plus/services/api_service.dart';
import 'package:kitt_plus/services/message_service.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:kitt_plus/services/theme.dart';
import 'package:kitt_plus/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();

  static bool getClickState(BuildContext context) {
    final state = context.findAncestorStateOfType<_ChatPageState>();
    return state?.click ?? false;
  }
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _googleAiScrollController = ScrollController();
  final _openAiScrollController = ScrollController();
  List<ChatMessage> googleAiMessages = [];
  List<ChatMessage> openAiMessages = [];
  List<bool> googleAiLoadingStates = [];
  List<bool> openAiLoadingStates = [];
  late bool isLoading;
  bool isFavorite = false;
  String paste = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    isLoading = false;
    googleAiLoadingStates = List.generate(1, (_) => false);
    openAiLoadingStates = List.generate(1, (_) => false);
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
                'assets/home/kitt_header.png',
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
                  setState(() {
                    click = !click;
                    isFavorite = !isFavorite;
                  });
                },
                child: isFavorite
                    ? Image.asset(
                        'assets/home/kitt_plus_dark.png',
                        fit: BoxFit.contain,
                        height: 38,
                      )
                    : Image.asset(
                        'assets/home/kitt_plus.png',
                        fit: BoxFit.contain,
                        height: 38,
                      ),
              ),
            ),
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
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  ).then((value) => setState(() {}));
                } else if (value == 1) {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Kitt.Plus + GoogleAI & OpenAI',
                    applicationVersion: '0.2.1',
                    applicationIcon: ClipRRect(
                      borderRadius: BorderRadius.circular(18), // Image border
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
                          'Flutter Chatbot App built with Gemini Pro + GPT Turbo'),
                      const Text('Developed by Kitt, LLC ©🐿️ 2019-2024'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        backgroundColor: AppColors.cardDark,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ResponsiveBuilder(
                  builder: (context, sizingInformation) {
                    Axis axis = Axis
                        .horizontal; // Default to horizontal on larger screens

                    // Check the screen type
                    if (sizingInformation.isMobile) {
                      axis =
                          Axis.vertical; // Set to vertical for mobile screens
                    }

                    return MultiSplitViewTheme(
                      data: MultiSplitViewThemeData(
                        dividerPainter: DividerPainters.grooved2(
                          backgroundColor: AppColors.burnt,
                          gap: 8,
                          thickness: 3,
                          color: AppColors.textLight,
                          highlightedColor: (click == false)
                              ? AppColors.secondary
                              : AppColors.neon,
                        ),
                      ),
                      child: MultiSplitView(
                        axis: axis, // Set the axis based on screen size
                        children: [
                          Stack(
                            children: [
                              ListView.builder(
                                controller: _googleAiScrollController,
                                itemCount: googleAiMessages.length,
                                itemBuilder: (context, index) {
                                  var message = googleAiMessages[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                          ClipboardData(text: message.text));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Message copied to clipboard"),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          right: 12.0, bottom: 9.0),
                                      color: message.chatMessageType ==
                                              ChatMessageType.bot
                                          ? AppColors.textDark
                                          : AppColors.cardDark,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: ChatMessageWidget(
                                              text: message.text,
                                              chatMessageType:
                                                  message.chatMessageType,
                                              source: message.source,
                                            ),
                                          ),
                                          if (message.chatMessageType ==
                                                  ChatMessageType.user ||
                                              message.chatMessageType ==
                                                  ChatMessageType.bot)
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                // Copy the message content to the clipboard
                                                Clipboard.setData(ClipboardData(
                                                    text: message.text));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Message copied to clipboard"),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (googleAiLoadingStates
                                  .any((loading) => loading))
                                Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                    leftDotColor: AppColors.neon,
                                    rightDotColor: AppColors.peach,
                                    size: 100,
                                  ),
                                ),
                            ],
                          ),
                          Stack(
                            children: [
                              ListView.builder(
                                controller: _openAiScrollController,
                                itemCount: openAiMessages.length,
                                itemBuilder: (context, index) {
                                  var message = openAiMessages[index];
                                  return GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(
                                          ClipboardData(text: message.text));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Message copied to clipboard"),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          right: 12.0, bottom: 8.0),
                                      color: message.chatMessageType ==
                                              ChatMessageType.bot
                                          ? AppColors.textDark
                                          : AppColors.cardDark,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: ChatMessageWidget(
                                              text: message.text,
                                              chatMessageType:
                                                  message.chatMessageType,
                                              source: message.source,
                                            ),
                                          ),
                                          if (message.chatMessageType ==
                                                  ChatMessageType.user ||
                                              message.chatMessageType ==
                                                  ChatMessageType.bot)
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: message.text));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Message copied to clipboard"),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (openAiLoadingStates.any((loading) => loading))
                                Center(
                                  child: LoadingAnimationWidget.twistingDots(
                                    leftDotColor: AppColors.peach,
                                    rightDotColor: AppColors.neon,
                                    size: 100,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: AppColors.burnt,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Material(
          color: AppColors.cardDark,
          elevation: 16,
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: TabBar(
              indicatorColor:
                  (click == false) ? AppColors.neon : AppColors.secondary,
              indicatorWeight: 5,
              tabs: <Tab>[
                Tab(
                  icon: Image.asset(
                    'assets/home/made_footer.png',
                    fit: BoxFit.contain,
                    height: 18,
                  ),
                ),
              ],
              controller: _tabController,
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: Row(
        children: [
          // Mic icon column
          Container(
            margin: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AvatarGlow(
                glowRadiusFactor: 1,
                glowShape: BoxShape.circle,
                animate: isListening,
                duration: const Duration(milliseconds: 2000),
                glowColor:
                    (click == false) ? AppColors.neon : AppColors.secondary,
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
          Tooltip(
            message: 'Send request to Google AI and OpenAI',
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: 8,
              ),
              child: GlowingActionButton(
                color: (click == false) ? AppColors.neon : AppColors.secondary,
                icon: CupertinoIcons.hare_fill,
                onPressed: () async {
                  if (_textController.text.isNotEmpty) {
                    var input = _textController.text;
                    _textController.clear();

                    // Call Google AI response
                    setState(() {
                      googleAiLoadingStates.add(true);
                    });
                    generateGoogleAiResponse(input).then((googleAiResponse) {
                      // Display user input and Google AI response
                      setState(() {
                        googleAiMessages.add(
                          ChatMessage(
                            text: input,
                            chatMessageType: ChatMessageType.user,
                            source: 'User',
                          ),
                        );

                        googleAiMessages.add(
                          ChatMessage(
                            text: googleAiResponse,
                            chatMessageType: ChatMessageType.bot,
                            source: 'GoogleAI',
                          ),
                        );
                        googleAiLoadingStates = [false];
                        _scrollGoogleAiDown();
                      });
                    });

                    // Call OpenAI response
                    setState(() {
                      openAiLoadingStates.add(true);
                    });
                    generateOpenAiResponse(input).then((openAiResponse) {
                      // Display OpenAI response
                      setState(() {
                        openAiMessages.add(
                          ChatMessage(
                            text: input,
                            chatMessageType: ChatMessageType.user,
                            source: 'User',
                          ),
                        );

                        openAiMessages.add(
                          ChatMessage(
                            text: openAiResponse,
                            chatMessageType: ChatMessageType.bot,
                            source: 'OpenAI',
                          ),
                        );
                        openAiLoadingStates = [false];
                        _scrollOpenAiDown();
                      });
                    });
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
          ),
        ],
      ),
    );
  }

  void _scrollGoogleAiDown() {
    // Delay scrolling to ensure new messages are added before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      _googleAiScrollController.animateTo(
        _googleAiScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollOpenAiDown() {
    // Delay scrolling to ensure new messages are added before scrolling
    Future.delayed(const Duration(milliseconds: 100), () {
      _openAiScrollController.animateTo(
        _openAiScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }
}
