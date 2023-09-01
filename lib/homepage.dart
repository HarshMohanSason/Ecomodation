import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class MainScreen extends StatefulWidget {

 // final String imagePath;
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  String handleSearch(String query) {
    // Process the search query here
    // print('Submitted query: $query');
    // Perform any necessary operations based on the search query
    return 'Search complete'; // Optionally, you can return a value of any type
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: colorTheme,
        body: Column(
          children: <Widget>[
           const Padding(padding: EdgeInsets.only(top:35,)),
            _searchbar(context),
            Expanded(
              child: _bottomIcons(context),
            ),
          ],
        )

      ),
    );
  }

  Widget _bottomIcons(BuildContext context) {

    var sizeofIcons = screenWidth/13; //Adjust size of Icons to screenWidth of each screen.

    return Row(
      //Return the icons in a row

      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:  <Widget>[
        Align(
          //Align the cont
          alignment: const Alignment(0, 0.9),
          child: IconButton(
            onPressed: null,
            icon: Icon(Icons.home, color: Colors.black, size: sizeofIcons),
          ),
        ),
       const Spacer(),
        Align(
          alignment: const Alignment(0, 0.90),
          child: IconButton(

            onPressed: ()  {

              Navigator.pushNamed(context, 'AddImagePage');

              },
            icon:
                Icon(Icons.add_a_photo, color: Colors.black, size: sizeofIcons),
          ),
        ),
        const Spacer(),
        Align(
          alignment: const Alignment(0, 0.91),
          child: IconButton(
            onPressed: null,
            icon:
            Icon(Icons.messenger_rounded, color: Colors.black, size: sizeofIcons),
          ),
        ),
      const  Spacer(),
        Align(
          alignment: const Alignment(0, 0.9),
          child: IconButton(
            onPressed: null,
            icon: Icon(Icons.settings, color: Colors.black, size: sizeofIcons),
          ),
        ),
      ],
    );
  }


  //Widget searchbar to place at the top.
  Widget _searchbar (BuildContext context){
    return AnimSearchBar(
            helpText: "Enter your location",
            width: screenWidth,
            textController: TextEditingController(),
            onSuffixTap: null,
            onSubmitted: handleSearch,
            rtl: true,
            color: Colors.black,
            searchIconColor: Colors.white,
    );
  }
}
