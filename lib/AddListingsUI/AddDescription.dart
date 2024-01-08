import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';

class AddDescription extends StatefulWidget {

  AddDescription({Key? key}) : super(key: key);



  @override

  State<AddDescription> createState() => _AddDescriptionState();

  static final descriptionController = TextEditingController();
  static final titleController = TextEditingController();


}

class _AddDescriptionState extends State<AddDescription> {

  final GlobalKey<FormState> addDescriptionAndTitleKey = GlobalKey<FormState>();

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 844); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }


  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: screenHeight/1.9,
      child: titleAndDescription(context),
    );
  }





  Widget titleAndDescription(BuildContext context)
  {
    return Form(
      key: addDescriptionAndTitleKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

           Align(
                alignment: Alignment.topCenter,
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
            padding: const EdgeInsets.only(top: 10),
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
        ],
      ),
    );
  }

}
