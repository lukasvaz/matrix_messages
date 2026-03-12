import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: Colors.blueGrey,
      child: Icon(Icons.person, color: Colors.white),
    );
  }
}
