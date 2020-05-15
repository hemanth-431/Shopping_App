

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Adobe extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<Adobe> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
       child: new Container(
         height: 36.00,
         width: 36.00,
         decoration: BoxDecoration(
           image: DecorationImage(
             image: AssetImage("assets/dsc1.png"),
           ),
         ),
       ),
      ),
    );
  }

}