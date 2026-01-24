library mensajeria.globals;

import 'package:flutter/material.dart';

const Color backgroundColor = Color(0xFFF2F2F2);
const Color dividerColor = Color(0xFFDCDCDC);

const Color orangeButton = Color(0xFFFF6600);

const Color primaryButtonColor = Color(0xFF4F4F69);
const Color secondaryButtonColor = Color(0xFF757575);
const Color disabledButtonColor = Color(0xFFBDBDBD);

const Color alertColorGray = Color(0xFFCCCCCC);
const Color alertColorYellow = Color(0xFFFFDE59);
const Color alertColorRed = Color(0xFFFF5757);

const Color primaryTextColor = Color(0xFF4F4F69);
const Color secondaryTextColor = Color(0xFF757575);
const Color disabledTextColor = Color(0xFFBDBDBD);

const Color completedTextColor = Color(0xFF999999);
const Color taskTextColor = Color(0xFF1A1A1A);
const Color suspendedTextColor = Color(0xFFA6A6A6);
const Color searchTextColor = Color(0xFFbbbcc9);

const Color channelsTextColor = Color(0xFF87888A);
const Color emptyChannelsColor = Color(0xFFDCDCDC);

Duration endingTaskTime = const Duration(
    minutes:
        5); // time to wait from completed to block a task (min: 30 secs), setting it as zero won't block the tasks