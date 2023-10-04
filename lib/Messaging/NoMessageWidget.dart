import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';

class NoMessageWidget extends StatelessWidget {
  const NoMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: const Alignment(-1,-0.8),
                child: IconButton (
                    onPressed: () {
                      Navigator.pushNamed(context, 'HomeScreen');
                    },
                    icon:  Icon(Icons.arrow_back_rounded, size: screenWidth/12, color: Colors.black)
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/5783800.jpg',
                  scale: 4,
                ),
              ),
              SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '''You will see messages here once people start 
                               contacting you''',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  color: Colors.black,
                      fontSize: screenWidth/23
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }








}