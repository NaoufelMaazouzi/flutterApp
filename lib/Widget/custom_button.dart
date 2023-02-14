import 'package:flutter/material.dart';

Widget customButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onClick,
        child: Row(
          children: [Icon(icon), Text(title)],
        ),
      ));
}
