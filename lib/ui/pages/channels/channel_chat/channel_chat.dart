import 'package:frontend/ui/pages/channels/channel_chat/widgets/chat_information.dart';
import 'package:frontend/ui/pages/channels/channel_chat/widgets/delete_message.dart';
import 'package:frontend/ui/pages/channels/channel_chat/widgets/name_builder.dart';
import 'package:frontend/ui/pages/channels/channel_chat/widgets/send_message.dart';
import 'package:frontend/ui/pages/widgets/bottom_nav_bar_widget.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ChannelChat extends StatefulWidget {
  final Room room;
  const ChannelChat({required this.room, super.key});

  @override
  ChannelChatState createState() => ChannelChatState();
}

class ChannelChatState extends State<ChannelChat> {
  late final Future<Timeline> _timelineFuture;
  List<types.Message> _messages = [];
  int _memberCount = 0;

  @override
  void initState() {
    super.initState();
    _timelineFuture = widget.room.getTimeline(onUpdate: () => _loadMessages());
    if (_messages.isEmpty) _loadMessages();
    _loadMemberCount();
  }

  void _loadMemberCount() {
    if (!mounted) return;
    final memberCount = widget.room.getParticipants().length;
    if (memberCount != _memberCount) {
      setState(() {
        _memberCount = memberCount;
      });
    }
  }

  types.TextMessage _mapEventToMessage(Event event, Timeline timeline) {
    final sender = event.senderFromMemoryOrFallback;
    return types.TextMessage(
        author: types.User(id: sender.id, firstName: sender.displayName),
        id: event.eventId,
        text: event.getDisplayEvent(timeline).body,
        createdAt: event.originServerTs.millisecondsSinceEpoch);
  }

  void _loadMessages() async {
    final timeline = await _timelineFuture;
    if (!mounted) return;
    setState(() {
      _messages = timeline.events
          .where((event) =>
              event.relationshipEventId == null &&
              event.type == 'm.room.message' &&
              event.content.isNotEmpty)
          .map((event) => _mapEventToMessage(event, timeline))
          .toList();
    });
  }

  Future<void> _deleteMessage(types.Message message) async {
    await widget.room.redactEvent(message.id);
  }

  void _showDeleteMessageBottomSheet(types.Message message) {
    if (message.author.id == widget.room.client.userID) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DeleteMessage(
            onDelete: () async {
              await _deleteMessage(message);
            },
          );
        },
      );
    }
  }

  Color _generateColorFromUserId(String userId) {
    final hash = userId.hashCode;
    var r = (hash & 0xFF0000) >> 16;
    var g = (hash & 0x00FF00) >> 8;
    var b = (hash & 0x0000FF);

    const int minIntensity = 100;
    const int maxIntensity = 200;

    r = (r * maxIntensity / 255).clamp(minIntensity, maxIntensity).toInt();
    g = (g * maxIntensity / 255).clamp(minIntensity, maxIntensity).toInt();
    b = (b * maxIntensity / 255).clamp(minIntensity, maxIntensity).toInt();

    if (r < maxIntensity && g < maxIntensity && b < maxIntensity) {
      final dominantChannel = hash % 3;
      if (dominantChannel == 0) r = maxIntensity;
      if (dominantChannel == 1) g = maxIntensity;
      if (dominantChannel == 2) b = maxIntensity;
    }

    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: ChatInformation(
            roomName: widget.room.name,
            memberCount: _memberCount,
            screenWidth: screenWidth,
            screenHeight: screenHeight),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: FutureBuilder<Timeline>(
                  future: _timelineFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container(
                          decoration:
                              const BoxDecoration(color: Color(0xFFF2F2F4)),
                          child:
                              const Center(child: CircularProgressIndicator()));
                    }

                    return Chat(
                        messages: _messages,
                        onSendPressed: (types.PartialText message) {},
                        onMessageLongPress: (context, message) {
                          _showDeleteMessageBottomSheet(message);
                        },
                        user: types.User(id: widget.room.client.userID!),
                        showUserNames: true,
                        showUserAvatars: true,
                        customBottomWidget: SendMessage(
                            room: widget.room,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onSend: (text) {
                              if (text.isNotEmpty) {
                                widget.room.sendTextEvent(text);
                              }
                            }),
                        customDateHeaderText: (date) {
                          final now = DateTime.now();
                          final diff = now.difference(date);
                          if (diff.inDays < 1) {
                            return 'Hoy';
                          } else if (diff.inDays < 2) {
                            return 'Ayer';
                          } else {
                            return '${date.day}/${date.month}/${date.year}';
                          }
                        },
                        dateHeaderThreshold: 86400000,
                        textMessageBuilder: (p0,
                                {required messageWidth, required showName}) =>
                            TextMessage(
                                emojiEnlargementBehavior:
                                    EmojiEnlargementBehavior.multi,
                                hideBackgroundOnEmojiMessages: false,
                                message: p0,
                                showName: showName,
                                usePreviewData: true,
                                nameBuilder: (p1) => NameBuilder(
                                    message: p0,
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    generateColorFromUserId:
                                        _generateColorFromUserId)),
                        avatarBuilder: (p0) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                                backgroundColor:
                                    _generateColorFromUserId(p0.id),
                                radius: screenHeight / screenWidth * 7,
                                child: Text(p0.firstName![0].toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            screenHeight / screenWidth * 7,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'OpenSans')))),
                        hideBackgroundOnEmojiMessages: false,
                        theme: const DefaultChatTheme(
                            backgroundColor: Color(0xFFF2F2F4),
                            primaryColor: Color(0xFFFF6600),
                            secondaryColor: Color(0xFFDCDCDC),
                            messageInsetsVertical: 10));
                  }))
        ])),
        bottomNavigationBar: BottomNavBarWidget(
            screenWidth: screenWidth, screenHeight: screenHeight, section: 2));
  }
}