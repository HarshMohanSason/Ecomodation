
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'UploadListing.dart';
import 'package:ecomodation/AddListingsUI//AddListing.dart';
import 'AddDescription.dart';


class ListingPrice extends StatefulWidget {
  const ListingPrice({Key? key}) : super(key: key);

  @override
  State<ListingPrice> createState() => _ListingPriceState();

  static final phoneText = TextEditingController(); //to control the text editing inside the textForm widget

}

class _ListingPriceState extends State<ListingPrice> with TickerProviderStateMixin {

  UploadListing newListing = UploadListing();
  final GlobalKey<FormState> priceForm = GlobalKey<FormState>();
  bool formValidated = false;
  bool isUploading = false;

  Future<void> verifyForm(BuildContext context) async {
    if (priceForm.currentState!.validate()) {
      formValidated = true;
    } else {
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
  Widget build(BuildContext context) {
    return  Expanded(
        child: listingPrice(context));
  }

  Widget listingPrice(BuildContext context) {
    return Form(
      key: priceForm,
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Align(
              alignment: Alignment.center,
              child: Text(
                'Price /mo',
                style: TextStyle(
                  fontSize: fontSize(context, 32),
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: screenWidth - 70,
              child: TextFormField(
                cursorColor: Colors.black,
                cursorWidth: 2,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                controller: ListingPrice.phoneText,
                cursorHeight: fontSize(context, 55),
                maxLines: 1,
                maxLength: 7,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                  RupeeInputFormatter()
                ],
                style: TextStyle(
                    fontSize: fontSize(context, 55),
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '\u20B9', //get the rupee symbol
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize(context, 60),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5), // Change the border color to your preference
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5), // Change the focused border color to your preference
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.red, // Change the error border color to your preference
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.red, // Change the focused error border color to your preference
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  var price = value;

                  if (price!.isEmpty) {
                    return 'Price cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const  EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
            onPressed: () async {

              await verifyForm(context); //make sure the form submitted is correct
              var isLocationUploaded = await newListing.checkIfLocationIsUploaded();

              if (formValidated == true && mounted && isLocationUploaded == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  // Prevent the user from dismissing the dialog
                  builder: (BuildContext context) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: colorTheme,
                          ),
                          DefaultTextStyle(
                            style: TextStyle(fontSize: screenWidth / 28),
                            child: const Text('Uploading...'),
                          )
                        ],
                      ),
                    );
                  },
                );

                  AddListing.allImages.clear();
                  AddDescription.descriptionController.clear(); //clear the description text from the description box
                  AddDescription.titleController.clear(); //clear the title text from the title box
                  ListingPrice.phoneText.clear(); //clear the phone price from the textbox

                  final pref = await SharedPreferences.getInstance();
                  pref.setDouble('LinearBarVal', 0.0);
                  pref.setInt('Index', 0);

                  if (mounted) {
                    Navigator.pushNamed(context, 'HomeScreen'); //Navigate back to the home screen once the listing has been uploaded to the database

                    Fluttertoast.showToast(
                      msg: 'Your listing has been uploaded',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  }
                }
              else
                {
                  Fluttertoast.showToast(
                    msg: 'No location found for the user. Need user location to upload a listing. Use the location button in the HomeScreen to get your location',
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 4,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
              fixedSize: MaterialStateProperty.all(Size(screenWidth - 20, screenHeight/19)),
              backgroundColor: const MaterialStatePropertyAll(
                  Colors.black), //set the color for the continue button
            ),
            child: Text(
              'Upload',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth/20,
              ),
            ),
              ),
            ),
          ),
        ],
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
