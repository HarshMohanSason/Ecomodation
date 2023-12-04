import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tf;

class Model //class for the AI Model
{
  late final interpreter ;
  List<List<double>> _output = [List<double>.filled(1, 0.0)]; //list to hold the output probability predicted by the model


  Future<void> loadModel() async { //function to load the model
    interpreter = await tf.Interpreter.fromAsset("assets/ImageDetectionModel.tflite"); //loading the model from the assets folder
  }


  Future<dynamic> preprocessImage(String imagePath) async { //function to preprocess the image first

    // Load the image using the image package
    ByteData data = await rootBundle.load(imagePath); //load the image from the imagePath

    final rawImage = img.decodeImage(data.buffer.asUint8List());//get the pixel values of the images

    // Resize the image to 150x150
    final resizedImage = img.copyResize(rawImage!, width: 150, height: 150); //resizing the image back to 150 x 150

    final normalizedImage = List.generate(resizedImage.height, (y) {   //normalize the image
      return List.generate(resizedImage.width, (x) {
        return [
          (resizedImage.getPixel(x, y) & 0xFF) / 255.0,              // Red channel
          ((resizedImage.getPixel(x, y) >> 8) & 0xFF) / 255.0,       // Green channel
          ((resizedImage.getPixel(x, y) >> 16) & 0xFF) / 255.0,      // Blue channel
        ];
      });
    });

    final imageInput = [normalizedImage];   //get the image input matrix
    interpreter.run(imageInput, _output); //run the model

    var result = _output.first;
   // print(result);

    return result;
  }
}