import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

/// Reusable AppBar builder for consistent styling across pages
PreferredSizeWidget buildCustomAppBar(String title) {
  return GFAppBar(
    backgroundColor: Colors.black,
    title: Text(
      title,
      style: const TextStyle(color: Color(0xFFFFC0CB)),
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
  );
}
