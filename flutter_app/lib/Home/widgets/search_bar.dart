import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onMicTap;
  final TextEditingController? controller;

  const SearchBar({super.key, this.onChanged, this.onMicTap, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, size: 22),
        suffixIcon: IconButton(
          onPressed: onMicTap,
          icon: const Icon(Icons.mic_none_rounded),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F2F7), // gris claro estilo iOS
      ),
    );
  }
}
