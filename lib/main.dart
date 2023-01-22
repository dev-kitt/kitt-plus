import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kitt_plus/env/env.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:clipboard/clipboard.dart';
import 'model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// This function is used to update the page title
void setPageTitle(String title, BuildContext context) {
  SystemChrome.setApplicationSwitcherDescription(ApplicationSwitcherDescription(
    label: title,
    primaryColor: Theme.of(context).primaryColor.value, // This line is required
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kitt | PLUS by Made, LLC',
      home: ChatPage(),
    );
  }
}

const IconData contentCopy = IconData(0xe190, fontFamily: 'MaterialIcons');
const backgroundColor = Color.fromRGBO(43, 43, 43, 1);
const botBackgroundColor = Color.fromRGBO(90, 90, 90, 1);
const greyAccentColor = Color.fromRGBO(217, 217, 217, 1);
const purpAccentColor = Color.fromRGBO(136, 86, 255, 1);
const pinkAccentColor = Color.fromRGBO(241, 146, 232, 1);
const neonAccentColor = Color.fromRGBO(105, 219, 136, 1);

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
    setPageTitle('Kitt | PLUS by Made, LLC', context);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/kitt_plus_gpt.png',
                  fit: BoxFit.contain,
                  height: 32,
                ),
              ],
            ),
          ),
          backgroundColor: backgroundColor,
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
                      _buildSubmit(),
                      //_buildCopy(),
                      //_buildPaste(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Material(
            color: backgroundColor,
            elevation: 16,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: TabBar(
                indicatorColor: purpAccentColor,
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

  // Widget _buildCopy() {
  //   return Visibility(
  //     visible: !isLoading,
  //     child: Container(
  //       color: botBackgroundColor,
  //       child: IconButton(
  //         icon: const Icon(
  //           Icons.content_copy,
  //           color: Color.fromRGBO(142, 142, 160, 1),
  //         ),
  //         onPressed: () async {
  //           // display user input
  //           await FlutterClipboard.copy(_textController.text);

  //           // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"),duration: Duration(milliseconds: 300),),);
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildPaste() {
  //   return Visibility(
  //     visible: !isLoading,
  //     child: Container(
  //       color: botBackgroundColor,
  //       child: IconButton(
  //         icon: const Icon(
  //           Icons.paste,
  //           color: Color.fromRGBO(142, 142, 160, 1),
  //         ),
  //         onPressed: () async {
  //           // display user input
  //           final value = await FlutterClipboard.paste();

  //           setState(() {
  //             paste = value;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: botBackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
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
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
            fillColor: botBackgroundColor,
            filled: true,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: TextStyle(
                fontSize: 12.0, color: Color.fromARGB(255, 255, 255, 255)),
            hintText: 'Ask Kitt+OpenAI ...'),
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
          ? botBackgroundColor
          : backgroundColor,
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
