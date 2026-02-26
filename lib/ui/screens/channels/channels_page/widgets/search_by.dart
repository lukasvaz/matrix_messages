import 'package:flutter/material.dart';

class SearchBy extends StatelessWidget {
  final TextEditingController searchController;
  final String searchText;
  final ValueChanged<String> onTextChanged;
  final double screenHeight;
  final double screenWidth;
  final VoidCallback onClear;

  const SearchBy(
      {super.key,
      required this.searchController,
      required this.searchText,
      required this.onTextChanged,
      required this.screenHeight,
      required this.screenWidth,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: SizedBox(
                width: screenWidth * 0.9,
                child: TextField(
                    controller: searchController,
                    style: TextStyle(
                        color: const Color(0xFFBBBCC9),
                        fontSize: screenWidth * 0.036,
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                        hintText: 'Buscar por carpeta o canal',
                        hintStyle: TextStyle(
                            color: const Color(0xFF6A6870),
                            fontSize: screenWidth * 0.036,
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.w500),
                        suffixIcon: searchText.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close_rounded,
                                    color: const Color(0xFFBBBCC9),
                                    size: screenWidth * 0.06),
                                onPressed: onClear,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero)
                            : null,
                        suffixIconConstraints:
                            BoxConstraints(maxHeight: screenHeight * 0.05),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.014),
                        isDense: true),
                    onChanged: onTextChanged))));
  }
}
