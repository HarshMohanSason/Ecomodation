import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';

class AddDescription extends StatefulWidget {
  const AddDescription({Key? key}) : super(key: key);

  @override

  State<AddDescription> createState() => _AddDescriptionState();

  static final descriptionController = TextEditingController();
  static final titleController = TextEditingController();

}



class _AddDescriptionState extends State<AddDescription> {
  final GlobalKey<FormState> addDescriptionAndTitleKey = GlobalKey<FormState>();
  Future<void> verifyForm(BuildContext context) async {

    if(addDescriptionAndTitleKey.currentState!.validate())
    {
      Navigator.pushNamed(context, 'AddPricePage');
    }
  }

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 844); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
       resizeToAvoidBottomInset: false,
       backgroundColor: Colors.white,
       body: SizedBox(
           height: screenHeight,
           child: titleAndDescription(context)),
      ),
    );
  }


  Widget titleAndDescription(BuildContext context)
  {
    return Form(
      key: addDescriptionAndTitleKey,
      child: Padding(

        padding:  EdgeInsets.only(top: screenHeight/11.65),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,

          children: [

            Align(
              alignment: const Alignment(-1,-0.8),
              child: IconButton (
                  onPressed: () {
                    Navigator.pushNamed(context, 'AddImagePage');
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),

              SizedBox(height: screenHeight/46.6),

             Align(
                  alignment: Alignment.center,
                  child: Text('Let\'s add some more information',
                      style: TextStyle(
                        fontSize: fontSize(context, screenWidth/21),fontWeight: FontWeight.bold
                  )),
              ),

              SizedBox(height: screenHeight/23.3),

               const Align(
               alignment: Alignment(-0.85, 0), //Align the heading 'title'
             child: Text('Title', style:
             TextStyle(
             fontWeight: FontWeight.bold,
             ))), //Heading for textform for entering the titl

            Padding(
              padding: EdgeInsets.only(top: 10),
              child: SizedBox(
                width: screenWidth - 20,
                child: Padding(
                  padding: const EdgeInsets.only(left:20.0),
                  child: TextFormField(
                   controller: AddDescription.titleController ,
                   cursorColor: colorTheme,
                   cursorWidth: 2,
                   maxLines: 1,
                   decoration: InputDecoration(
                   border: OutlineInputBorder(
                   borderSide: const BorderSide(width: 2.0, color: Colors.black),
                   borderRadius: BorderRadius.circular(20),
                   ),
                   ),
                   validator: (value)
                   {
                   if(value!.isEmpty)
                   {
                   return 'Title cannot be empty';
                   }
                   return null;
                   },
                   ),
                ),
              ),
            ),

           SizedBox(height: screenHeight/23),

            const Align(
                alignment: Alignment(-0.77,0),  //Align the heading 'title'
                child: Text('Description (optional)', style:
                  TextStyle(
                    fontWeight: FontWeight.bold,
                  ),)),

               Padding(
                 padding: const EdgeInsets.only(top: 10),
                 child: SizedBox(
                   width: screenWidth - 20,
                   child: Padding(
                     padding: const EdgeInsets.only(left: 20.0),
                     child: TextFormField(
                       textInputAction: TextInputAction.done,
                     cursorColor: colorTheme,
                     cursorWidth: 2,
                     controller: AddDescription.descriptionController,
                     textAlignVertical: TextAlignVertical.top,
                     maxLines: 7,
                     decoration: InputDecoration(
                     hintText: 'Listings with detailed descriptions sell better!',
                     isDense:  true,
                     // contentPadding: const EdgeInsets.all(100),
                     border: OutlineInputBorder(

                       borderSide: const BorderSide(width: 2, color: Colors.black),
                     borderRadius: BorderRadius.circular(20),

                     ),
                     ),
                     validator: (value)
                     {
                     return null;
                     },
                     ),
                   ),
                 ),
               ),

            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Align(
                alignment: const Alignment(0,0.83),
                  child: ElevatedButton(
                    onPressed: () async {

                      await verifyForm(context);},

                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          )),
                      fixedSize: MaterialStateProperty.all(Size(screenWidth - 50, screenHeight/19)),
                      backgroundColor: const MaterialStatePropertyAll(
                          colorTheme), //set the color for the continue button
                    ),
                    child:  Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize(context, 18),
                      ),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
