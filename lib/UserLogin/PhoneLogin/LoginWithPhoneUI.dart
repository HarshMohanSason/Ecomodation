
import 'package:ecomodation/UserLogin/PhoneLogin/OTPpageUI.dart';
import 'package:ecomodation/UserLogin/PhoneLogin/PhoneAuthService.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../InternetChecker.dart';


String phoneLoginDocID = ' '; //Get the documentID for the PhoneLogin

class LoginWithPhone extends StatefulWidget {
   const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();

}

class _LoginWithPhoneState extends State<LoginWithPhone>
{

  final _phoneLoginKey = GlobalKey<FormState>(); //key for the form.
  final phoneTextController = TextEditingController(); //Control the phone number entered in the textForm field
  bool phoneNumberValidated = true; //Flag to check whether the phone number is validated or not

  Future<void> verifyForm(BuildContext context) async { //Verify form which checks the form, reads data from the database and logs user in with their phone number

    final phoneProvider = Provider.of<PhoneAuthService>(context, listen: false);
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection(); // Check internet connection
    if (_phoneLoginKey.currentState!.validate()) { //check if the form is validated or not

      if (ip.hasInternet) {
        try {
          final otpVerificationID = await phoneProvider.sendOTP(phoneTextController.text);
          if(mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              // Prevent the user from dismissing the dialog
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: colorTheme,
                  ),
                );
              },
            );
            Navigator.push(context, MaterialPageRoute(builder: (context) => OtpUI(phoneNo: phoneTextController.text, verificationId: otpVerificationID)));
          }
        } catch (e) {
          Fluttertoast.showToast(
            msg: 'An error occurred, try again',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          );

        }
      }
      else
        {
            // Display a toast message if there is no internet connection
            Fluttertoast.showToast(
              msg: 'Check your Internet Connection',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.white,
              textColor: Colors.black,
            );
            if(mounted) {
              Navigator.pop(context);
            }
        }
    }
  }


  @override
  void dispose()
  {
    super.dispose();
    phoneTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final phoneProvider = context.watch<PhoneAuthService>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: phoneProvider.isLoading? const Center(
          child: CircularProgressIndicator() ): Column(children: <Widget>[
            phoneLoginForm(context) //call the phone login form in the body
          ]),
        ),
    );
  }

  Widget phoneLoginForm(BuildContext context)  //Build the phone login form
  {
    return Form(
       key: _phoneLoginKey,  //key for the loginPhoneForm
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(  //Put all the textForm fields in a column widget
              children: <Widget> [
                Align(
                  alignment: const Alignment(-1,-0.8),
                  child: IconButton (
                      onPressed: () {
                        Navigator.pushNamed(context, 'AppIntroUI');
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
                  ),
                ),
               const SizedBox(height: 20),
                phoneTextForm(context),//Call the phone textform

              ],
          ),
        ),

    );
  }


  /*--------------------- Build the text field form for entering the phone number----------------- */
  Widget phoneTextForm(BuildContext context) {

    return SizedBox(
      width: screenWidth - 20,
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLength: 10,
        cursorColor: Colors.black,
        cursorWidth: 2,
        controller: phoneTextController,
        style: TextStyle(
          fontSize: screenWidth/20,
          color: Colors.black, // Change the text color to your preference
        ),
        decoration: InputDecoration(
          suffixIcon: InkWell(
              onTap: () async
              {
                await verifyForm(context);
              },

              child: const Icon(Icons.arrow_forward)),
          hintText: '+91',
          hintStyle: TextStyle(
            fontSize: screenWidth/20,
            color: Colors.grey, // Change the hint text color to your preference
          ),
          helperText: 'Enter your phone number',
          helperStyle: TextStyle(
            fontSize: screenWidth/25,
            color: Colors.grey, // Change the helper text color to your preference
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5), // Change the border color to your preference
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5), // Change the focused border color to your preference
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.red, // Change the error border color to your preference
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.red, // Change the focused error border color to your preference
              width: 2,
            ),
          ),
        ),
        validator: (text) {
          final nonNumericRegExp = RegExp(r'^[0-9]+$');
          if (text!.isEmpty) {
            return 'Please enter a valid phone number';
          }
          if (!nonNumericRegExp.hasMatch(text)) {
            return 'Phone number must contain only digits';
          }
          if (text.length < 10) {
            return 'Number should be a ten digit number';
          }
          return null;
        },
      ),
    );
  }
}
