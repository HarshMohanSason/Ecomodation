
import 'package:ecomodation/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget{

  const TermsAndConditions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text('Terms and Conditions',
              style: TextStyle(

                fontSize: screenWidth/13,
              ),)
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 5),
              child: Text("Nothing",
                style: TextStyle(
                  fontSize: screenWidth/22,
                ),)
          ),
        ));
  }

}

