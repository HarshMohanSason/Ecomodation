

import 'package:just_audio/just_audio.dart';

class MessageSound {   //MessageSound class to deal with playing audio each time a user sends a message


  Future<void> playSound(String soundSource) async  //Future function to play a sound..
  {
    AudioPlayer playSound = AudioPlayer();  //Instance for Audio Player class
    playSound.setAsset(soundSource);  //set the Asset to load the current Audio
    playSound.play();  //play the Sound
  }

}