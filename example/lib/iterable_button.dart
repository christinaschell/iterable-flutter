import 'package:flutter/material.dart';

class IterableButton extends StatelessWidget {
  IterableButton({required this.title, required this.onPressed});
  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text(title.toUpperCase(), style: TextStyle(fontSize: 14)),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(color: Colors.blue)))),
        onPressed: () {
          onPressed();
        });
  }
}
