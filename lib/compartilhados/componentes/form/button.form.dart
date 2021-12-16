import 'package:flutter/material.dart';

class ButtonForm extends StatelessWidget {
  final String text;
  final IconData icon;
  final String nav;

  const ButtonForm({Key key, this.text, this.icon, this.nav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 7,
      color: Colors.red,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return null;
          }));
          print("Avançar");
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.symmetric(horizontal: 92, vertical: 15),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
