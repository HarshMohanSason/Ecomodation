
import 'dart:ui';
import 'package:ecomodation/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {

  const PrivacyPolicy({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:  Text("Privacy Policy", style: TextStyle(

            fontSize: screenWidth/13
        ),),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionText(
                    'This Privacy Policy describes how Ecomodation ("we," "us," or "our") collects, uses, and shares personal information of users of our apartment renting mobile application (the "Ecomodation"). We respect your privacy and are committed to protecting it through our compliance with this policy.'
                ),
                _sectionTitle('Information We Collect'),
                _sectionSubtitle('Information You Provide to Us:'),
                _bulletPoint(
                    'Personal Information such as name, email address, and location when you register for an account, submit inquiries, or communicate with us.'),
                _bulletPoint(
                    'Information you provide when you complete forms in the App, including search queries, preferences, and feedback.'),
                _sectionSubtitle('Information We Collect Automatically:'),
                _bulletPoint(
                    'Usage Details: When you access and use the App, we may automatically collect certain details of your access to and use of the App, including traffic data, location data, logs, and other communication data and the resources that you access and use on or through the App.'),
                _bulletPoint(
                    'Device Information: We may collect information about your mobile device and internet connection, including the device\'s unique device identifier, IP address, operating system, browser type, mobile network information, and the device\'s telephone number.'),
          
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                    child: _sectionTitle('How We Use Your Information')),
                _sectionText(
                    'We may use information that we collect about you or that you provide to us, including any personal information:'
                ),
                _bulletPoint(
                    'To provide you with the App and its contents, and any other information, products, or services that you request from us.'),
                _bulletPoint(
                    'To fulfill any other purpose for which you provide it.'),
                _bulletPoint(
                    'To carry out our obligations and enforce our rights arising from any contracts entered into between you and us, including for billing and collection.'),
                _bulletPoint(
                    'To notify you about changes to the App or any products or services we offer or provide though it.'),
                _bulletPoint(
                    'To improve the App and to deliver a better and more personalized experience, including by enabling us to estimate our audience size and usage patterns.'),
                _bulletPoint(
                    'To allow you to participate in interactive features of our App.'),
                _bulletPoint('For any other purpose with your consent.'),
                Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: _sectionTitle('Disclosure of Your Information')),
                _sectionText(
                    'We do not sell, trade, or otherwise transfer your personal information to third parties. We may disclose aggregated information about our users without restriction.'
                ),
                _sectionTitle('Data Security'),
                _sectionText(
                    'We take the security of your personal information seriously. We use RSA encryption for chat communication within the App to ensure that your conversations are secure and private. This encryption protocol helps protect your messages from unauthorized access.'
                ),
                _sectionTitle('Changes to Our Privacy Policy'),
                _sectionText(
                    'We may update our Privacy Policy from time to time. If we make material changes to how we treat our users\' personal information, we will notify you by email to the primary email address specified in your account and/or through a notice on the App home screen. Your continued use of the App after such modifications will constitute your acknowledgment of the modified Privacy Policy and agreement to abide and be bound by the modified Privacy Policy.'
                ),
                _sectionTitle('Contact Information'),
                _sectionText(
                    'If you have any questions about this Privacy Policy, please contact us at harshsason2000@gmail.com.'
                ),
                _sectionText(
                    'By using the App, you consent to our Privacy Policy and agree to its terms.'
                ),
                _sectionText(
                    'This Privacy Policy was last updated on March2, 2024.'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth/20,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8),
      child: Text(
        subtitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenWidth/24,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth / 22,
        ),
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(Icons.circle, size: screenWidth / 40,)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: screenWidth / 22),
            ),
          ),
        ],
      ),
    );
  }
}