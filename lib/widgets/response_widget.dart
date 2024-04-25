import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:kitt_plus/pages/chat.dart';
import 'package:kitt_plus/services/message_service.dart';
import 'package:kitt_plus/services/theme.dart';
import 'package:markdown/markdown.dart' as md;

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.chatMessageType,
    required this.source,
  });

  final String text;
  final ChatMessageType chatMessageType;
  final String source;

  @override
  Widget build(BuildContext context) {
    bool clickState = ChatPage.getClickState(context);

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
                    child: source == 'GoogleAI'
                        ? Image.asset(
                            'assets/chat/google_bot.png',
                            scale: 0.5,
                          )
                        : Image.asset(
                            'assets/chat/openai_bot.png',
                            scale: 0.5,
                          ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 18.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: (clickState == false)
                        ? Image.asset(
                            'assets/chat/kitt_bot_dark.png',
                            scale: 0.5,
                          )
                        : Image.asset(
                            'assets/chat/kitt_bot.png',
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
                                  child: Image.network(text, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ],
                        )
                      : MarkdownBody(
                          selectable: true,
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white),
                            h1: const TextStyle(color: AppColors.peach),
                            h2: const TextStyle(color: AppColors.peach),
                            h3: const TextStyle(color: Colors.white),
                            h4: const TextStyle(color: Colors.white),
                            h5: const TextStyle(color: Colors.white),
                            h6: const TextStyle(color: Colors.white),
                            listBullet: const TextStyle(color: AppColors.neon),
                          ),
                          extensionSet: md.ExtensionSet(
                            md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                            <md.InlineSyntax>[
                              md.EmojiSyntax(),
                              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                            ],
                          ),
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
