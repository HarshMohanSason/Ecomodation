import 'package:flutter/material.dart';
import 'dart:math';

class AddListingState extends ChangeNotifier {

double _angle = 0.0;
double _zoomLevel = 0.0;

set angle(double newAngle) //setter method to set the value of the angle;
{
  _angle = newAngle;
}

double get angle => _angle; //getter function to get the angle
double get zoomLevel => _zoomLevel; // getter function to get the zoomlevel;


void calcAngle()  //function to calculate the value of angle
{
  double degrees = -90.0;  //set degrees to -90 because we need to rotate the image by that.
  _angle += degrees * pi / 180;  //convert to radians.
  notifyListeners(); //notify the listeners about the angle change
}

void updateZoomLevel(double? updatedZoomLevel)
{
  _zoomLevel = updatedZoomLevel!;
  notifyListeners();
}

}