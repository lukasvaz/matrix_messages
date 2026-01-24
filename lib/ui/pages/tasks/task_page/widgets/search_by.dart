import 'package:flutter/material.dart';

class SearchBy extends StatelessWidget {
  final TextEditingController controller;
  final String searchText;
  final double screenWidth;
  final double screenHeight;
  final ValueChanged<String> onChanged;

  const SearchBy(
      {super.key,
      required this.controller,
      required this.searchText,
      required this.screenWidth,
      required this.screenHeight,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: TextField(
            controller: controller,
            style: TextStyle(
              color: const Color(0xFF6A6870),
              fontSize: screenWidth * 0.036,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar',
              hintStyle: TextStyle(
                  color: const Color(0xFF6A6870),
                  fontSize: screenWidth * 0.036,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.w600),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFBBBCC9),
                        size: screenWidth * 0.06,
                      ),
                      onPressed: () {
                        onChanged('');
                        controller.clear();
                      },
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero)
                  : null,
              suffixIconConstraints: BoxConstraints(
                maxHeight: screenHeight * 0.05,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.014),
              isDense: true,
            ),
            onChanged: onChanged));
  }
}
