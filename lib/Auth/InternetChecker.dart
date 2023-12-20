import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckInternet {

  Future<bool> checkInternet() async
  {
   try
   {
     return await InternetConnectionChecker().hasConnection;
   }
   catch(e)
    {
      rethrow;
    }
  }

}


