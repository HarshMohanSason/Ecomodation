
import 'package:ecomodation/AddListingsUI/AddDescription.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart';
import 'AddListing.dart';
import 'ListingPrice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListingProgressBar extends StatefulWidget {

  const ListingProgressBar({Key? key}) : super(key: key);

  @override
  State<ListingProgressBar> createState() => _ListingProgressBarState();

}


class _ListingProgressBarState extends State<ListingProgressBar> with TickerProviderStateMixin{

  late AnimationController progressBarController;
  int currIndex = 0;
  static  List<Widget> widgetScreens = [const AddListing(), AddDescription(), const ListingPrice()];
  double barProgressVal = 0.0;

  void updateBarProgress()
  {
    setState(() {
      barProgressVal += 0.5;
      if(barProgressVal > 1)
        {
          barProgressVal = 1;
        }
    });
  }



  @override
  void initState() {

   loadState();  //load the state of currIndex and barProgressVal
    progressBarController = AnimationController
      (vsync: this,
      duration: const Duration(seconds: 5)
    )..addListener(()
    {
      setState(() {
      });
    });
    super.initState();
  }


  @override
  void dispose() {
    progressBarController.dispose();
    super.dispose();
  }


  Future<void> loadState() async
  {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('Index'))
      {
        currIndex = prefs.getInt('Index')!;
      }

   if(prefs.containsKey('LinearBarVal'))
     {
       progressBarController.value = prefs.getDouble('LinearBarVal')!;
     }

   else
     {
       return;
     }
  }

  Future<void> writeState( ) async {

    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('Index') || prefs.containsKey('Index'))
    {
      prefs.setInt('Index', currIndex);
    }

    if(!prefs.containsKey('LinearBarVal') || prefs.containsKey('LinearBarVal'))
    {
      prefs.setDouble('LinearBarVal', progressBarController.value);
    }

}

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: progressBarController.value > 0.5 ? true : false,
          body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: LinearProgressIndicator(
              value: progressBarController.value,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              backgroundColor: Colors.grey,
              minHeight: 8,
            ),
          ),

          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {

                      setState(() {
                        writeState();
                        if(progressBarController.value > 0) {
                          currIndex --;
                          progressBarController.value -= 0.5;
                        }
                        else if(currIndex != 0)
                          {
                            Navigator.pop(context);
                          }
                        else
                          {
                            writeState();
                            Navigator.pushNamed(context, 'HomeScreen');
                          }
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded,
                        size: 35, color: Colors.black)),
              ),
              const Spacer(),
              InkWell(
                onTap: ()
                {
                  writeState();
                  Navigator.pushNamed(context, 'HomeScreen');
                },
                child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text("Cancel", style:
                    TextStyle(
                      fontSize: screenWidth/26,
                      fontWeight: FontWeight.bold,
                    ),)),
              ),
            ],
          ),

          widgetScreens[currIndex],

          if(currIndex == 0 || currIndex == 1)...[

          const Spacer(),

          _nextButton(),
        ]

        ],


      )),
    );
  }


  Widget _nextButton()
  {

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () async {
            setState(() {

            if(currIndex == 0 && AddListing.allImages.isNotEmpty || currIndex == 1)
                {
                  writeState();
                  if(currIndex < widgetScreens.length -1)
                  {
                    currIndex ++;
                  }
                  progressBarController.value += 0.5;
                  progressBarController.animateTo(progressBarController.value, duration: const Duration(seconds: 10));
                }
              else
                {
                  if(currIndex == 0)
                    {
                        Fluttertoast.showToast(
                          msg: 'Please add at least one Image',
                         toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                    }
                }
            });
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            )),
            fixedSize: MaterialStateProperty.all(
                Size(screenWidth - 50, screenHeight / 19)),
            backgroundColor: const MaterialStatePropertyAll(
                Colors.black), //set the color for the continue button
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
