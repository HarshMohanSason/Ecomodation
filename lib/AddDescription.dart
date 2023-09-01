import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';

class AddDescription extends StatefulWidget {
  const AddDescription({Key? key}) : super(key: key);

  @override
  State<AddDescription> createState() => _AddDescriptionState();
}

class _AddDescriptionState extends State<AddDescription> with AutomaticKeepAliveClientMixin <AddDescription>{


  static final descriptionController = TextEditingController();
  static final titleController = TextEditingController();

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 844); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }




  @override
  Widget build(BuildContext context) {

    super.build(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
       resizeToAvoidBottomInset: false,
       backgroundColor: Colors.white,
       body: titleAndDescription(context),
      ),
    );
  }


  Widget titleAndDescription(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
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

           const SizedBox(height: 20),

           Align(
                alignment: Alignment.center,
                child: Text('Let\'s add some more info to your listing',
                    style: TextStyle(
                      fontSize: fontSize(context, 18),fontWeight: FontWeight.bold
                )),
            ),

           const  SizedBox(height: 40),

             const Align(
             alignment: Alignment(-0.95, 0), //Align the heading 'title'
           child: Text('Title', style:
           TextStyle(
           fontWeight: FontWeight.bold,
           ))), //Heading for textform for entering the titl

             title(),

         const  SizedBox(height: 40),

          const Align(
              alignment: Alignment(-0.95,0),  //Align the heading 'title'
              child: Text('Description (optional)', style:
                TextStyle(
                  fontWeight: FontWeight.bold,
                ),)),

          description(context),

          Flexible(
            child: Align(
              alignment: const Alignment(0,0.77),
                child: nextPageButton(context)),
          ),
        ],
      ),
    );
  }


  Widget title()
  {
    return TextFormField(
      controller: titleController,
      cursorColor: colorTheme,
      cursorWidth: 2,
      maxLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
             borderSide: const BorderSide(width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
       ),
    );
  }

  Widget description(BuildContext context)
  {
    return TextFormField(
      cursorColor: colorTheme,
      cursorWidth: 2,
      controller: descriptionController,
      textAlignVertical: TextAlignVertical.top,
      maxLines: 10,
         decoration: InputDecoration(
          hintText: 'Listings with detailed descriptions sell better!',
          isDense:  true,
         // contentPadding: const EdgeInsets.all(100),
          border: OutlineInputBorder(
        //    borderSide: const BorderSide(width: 10.0),
          borderRadius: BorderRadius.circular(20),
          ),
        ),
    );
  }

  /* Widget to build the "Next" button*/
  Widget nextPageButton(BuildContext context){

    return  ElevatedButton(
      onPressed: () =>  Navigator.pushNamed(context, 'AddPricePage'),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),)),
        fixedSize: MaterialStateProperty.all(Size(screenWidth - 10, screenHeight/38)),
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
