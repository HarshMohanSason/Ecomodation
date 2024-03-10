
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';


class NoMessageWidget extends StatelessWidget {
  const NoMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset('assets/images/NoMessageImage.jpg',
                  scale: 4,
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'You will see messages here once people start contacting you',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    color: Colors.black,
                        fontSize: screenWidth/23
                    ),
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
