import 'package:flutter/material.dart';

class AppColors {
  static const Color level_1 = Color(0xFF05161A);
  static const Color level_2 = Color(0xFF072E33);
  static const Color level_3 = Color(0xFF0C7075);
  static const Color level_4 = Color(0xFF00F69C);
  static const Color level_5 = Color(0xFF6DA5C0);
  static const Color level_6 = Color(0xFF294D61);
}

class MyButtonStyle {
  BoxDecoration decorateBox() {
    return BoxDecoration(
      borderRadius:
          BorderRadius.circular(25), // Adjust the border radius as needed
      gradient: const LinearGradient(
        colors: [AppColors.level_2, AppColors.level_3],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ],
    );
  }
}
