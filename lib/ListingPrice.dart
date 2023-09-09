import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter/services.dart';
import 'UploadListing.dart';


class ListingPrice extends StatefulWidget {
  const ListingPrice({Key? key}) : super(key: key);

  @override
  State<ListingPrice> createState() => _ListingPriceState();

  static final phoneText = TextEditingController(); //to control the text editing inside the textForm widget

}

class _ListingPriceState extends State<ListingPrice> with TickerProviderStateMixin{



  UploadListing newListing = UploadListing();
  final priceForm = GlobalKey<FormState>(); //key to verify the form when submitted

  bool formValidated = false;
  bool isUploading = false;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: Duration(seconds:10)
    );
    controller.repeat(reverse: false);

  }


  // Create a reference to the user's document in the 'userInfo' collection

  Future<void> verifyForm(BuildContext context) async
  {

    if(priceForm.currentState!.validate())
      {
        formValidated = true;
      }
    else
      {
        formValidated = false;
      }
  }

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 844); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }

  @override
  Widget build(BuildContext context)
  {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: listingPrice(context),
      ),
    );
  }

  Widget listingPrice(BuildContext context){

    return Padding(
      padding:  const EdgeInsets.only(top: 80),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          Align(
            alignment: const Alignment(-1,-0.8),
            child: IconButton (
                onPressed: () {
                  Navigator.pushNamed(context, 'AddDescriptionPage');
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
            ),
          ),

          Align(
            alignment: Alignment.center,
              child: Text('Price',
                style: TextStyle(
                  fontSize: fontSize(context, 32),
                  fontWeight: FontWeight.bold,
                )
                ,)),

          const SizedBox(height: 20),

          Align(
              alignment: Alignment.center,
              child: addPrice(context)),

          Expanded(child:
          Align(
              alignment: Alignment(0,0.87),
              child: uploadButton(context))),
        ],
      ),
    );
  }

  Widget addPrice(BuildContext context){

    return SizedBox(
      width: screenWidth-70,
      child: Form(
        key: priceForm,
        child: TextFormField(
          cursorColor: colorTheme,
          cursorWidth: 4,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          controller: ListingPrice.phoneText,
          cursorHeight: fontSize(context, 55),
          maxLines: 1,
         inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7), RupeeInputFormatter()],
          style: TextStyle(fontSize: fontSize(context, 55), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '\u20B9', //get the rupee symbol
            hintStyle:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize(context, 60),
            ),

            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 2.0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          validator: (value)
          {
            var price = value;

            if(price!.isEmpty)
              {
                return 'Price cannot be empty';
              }
            return null;
          },
        ),
      ),
    );
  }

  Widget uploadButton(BuildContext context)

  {
    return  ElevatedButton(

      onPressed: () async
      {
       await verifyForm(context);  //make sure the form submitted is correct

       if(formValidated == true) {
         showDialog(
           context: context,
           barrierDismissible: false, // Prevent the user from dismissing the dialog
           builder: (BuildContext context) {
             return Center(
               child: CircularProgressIndicator(
                 color: colorTheme,
               ),
             );
           },
         );

         await newListing.checkLoginMethod();

         Navigator.pushNamed(context, 'HomeScreen'); //Navigate back to the home screen once the listing has been uploaded to the database

         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             duration: Duration(seconds:1),
             backgroundColor: Colors.black,
             content: const Padding(
                 padding: EdgeInsets.only(left: 100),
                 child: Text("Your Listing has been uploaded!", style: TextStyle(
                   color: Colors.white,
                 ),)),
             behavior: SnackBarBehavior.floating,
             margin: EdgeInsets.all(screenWidth/18),
             shape: const StadiumBorder(),
             action: SnackBarAction(
               label: '',
               onPressed: () {
               },
             ),
           ),
         );
       }
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),)),
        fixedSize: MaterialStateProperty.all(Size(screenWidth - 10, screenHeight/38)),
        backgroundColor: const MaterialStatePropertyAll(
            colorTheme), //set the color for the continue button
      ),

      child:  Text(
        'Upload',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize(context, 18),
        ),
      ),
    );
  }
}

/* Separate class to add the rupee symbol whenever the user enters any amount in the TextForm field. */

class RupeeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      return TextEditingValue(
        text: '\u20B9${newValue.text}',
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
    }
    return newValue;
  }
}
