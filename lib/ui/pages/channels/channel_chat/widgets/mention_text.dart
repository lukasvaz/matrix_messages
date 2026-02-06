import 'package:flutter/material.dart';
import 'package:matrix_messages/globals.dart';
import 'package:matrix/matrix.dart';

class MentionTextField extends StatefulWidget {
  final Room room;
  final TextEditingController controller;
  final Function(String mentionText) onMentionSelected;

  const MentionTextField(
      {required this.room,
      required this.controller,
      required this.onMentionSelected,
      super.key});

  @override
  MentionTextFieldState createState() => MentionTextFieldState();
}

class MentionTextFieldState extends State<MentionTextField> {
  List<User> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _updateSuggestions(widget.controller.text);
  }

  void _updateSuggestions(String query) {
    if (query.endsWith('@')) {
      setState(() {
        _suggestions = widget.room.getParticipants();
        _showSuggestions = true;
      });
    } else if (query.contains('@')) {
      final name = query.split('@').last;
      setState(() {
        _suggestions = widget.room.getParticipants().where((user) {
          return user.displayName?.toLowerCase().contains(name.toLowerCase()) ??
              false;
        }).toList();
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  void _insertMention(String mentionText) {
    final text = widget.controller.text;
    final mentionIndex = text.lastIndexOf('@');
    final newText = text.substring(0, mentionIndex + 1);

    widget.controller.value = TextEditingValue(
        text: newText,
        selection:
            TextSelection.fromPosition(TextPosition(offset: newText.length)));

    setState(() => _showSuggestions = false);
    widget.onMentionSelected(mentionText);
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
    double screenProportion =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    return Column(children: [
      if (_showSuggestions)
        Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 4),
            constraints: const BoxConstraints(maxHeight: 222),
            decoration: const BoxDecoration(color: backgroundColor),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final user = _suggestions[index];
                  final displayName = user.displayName ?? user.id;

                  return ListTile(
                      leading: CircleAvatar(
                          backgroundColor: _generateColorFromUserId(user.id),
                          child: Text(displayName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white))),
                      title: Text(displayName,
                          style: TextStyle(
                              color: const Color(0xFF727287),
                              fontSize: screenProportion * 8,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'OpenSans')),
                      onTap: () {
                        _insertMention(displayName);
                      });
                })),
      Stack(children: [
        Positioned.fill(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: RichText(
                    text: TextSpan(
                        style: const TextStyle(fontSize: 16.0),
                        children: _getStyledText(widget.controller.text))))),
        TextField(
            controller: widget.controller,
            cursorColor: const Color(0xFFF4A14C),
            decoration: InputDecoration(
                hintText: 'Mensaje...',
                hintStyle: TextStyle(
                    color: const Color(0xFF727287),
                    fontSize: screenProportion * 8,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'OpenSans'),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 8, horizontal: screenProportion * 8),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Color(0xffdcdcdc))),
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide:
                        BorderSide(color: Color(0xffdcdcdc), width: 1.5)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide:
                        BorderSide(color: Color(0xffdcdcdc), width: 2))),
            style: TextStyle(
                color: const Color(0xFF727287),
                fontSize: screenProportion * 8,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans'),
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            scrollPhysics: const ScrollPhysics())
      ])
    ]);
  }

  List<TextSpan> _getStyledText(String text) {
    const mentionColor = Color(0xFFF4A14C);
    final words = text.split(' ');
    return words.map((word) {
      if (word.startsWith('@')) {
        return TextSpan(
            text: '$word ', style: const TextStyle(color: mentionColor));
      } else {
        return TextSpan(
            text: '$word ', style: const TextStyle(color: Colors.black));
      }
    }).toList();
  }
}