import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  //final String userId;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue){
    isFavorite=newValue;
    notifyListeners();
  }


  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final olsdStatus=isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final  url = 'https://shoppingapp-fbd74.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';//update in database
   try{
     final response=  await http.put(url,body: json.encode(
      isFavorite,
     ));
  /* final response=  await http.patch(url,body: json.encode({
       'isFavorite':isFavorite,
     }));

   */
   if(response.statusCode >= 400)
     {
     _setFavValue(olsdStatus);

     }
   }catch(error){
     isFavorite=olsdStatus;

   }

  }
}

