import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_steps_tracker/app/home/shop/models/shop.dart';
import 'package:flutter_steps_tracker/models/bought_item.dart';
import 'package:flutter_steps_tracker/utils/constants.dart';

class MyDatabase with ChangeNotifier {
  MyDatabase({required this.uid, required this.name});
  final String name;
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _points = 0;
  final List<BoughtItem> _allBoughtItems = [];

  List<BoughtItem> get allBoughtItems {
    return [..._allBoughtItems];
  }

  int get points {
    return _points;
  }

  Future<void> initDatabase() async {
    final userData = await _firestore.collection("users").doc(uid).get();
    final mydoc = userData.data();
    if (mydoc?["points"] != null) {
      _points = mydoc!["points"];
    }
    if (mydoc?["buyLog"] != null) {
      for (var boughtItem in mydoc!["buyLog"]) {
        _allBoughtItems.add(BoughtItem.fromMap(boughtItem));
      }
    }
  }

  Future<void> deleteAccount() async{
    try{
      await _firestore.collection('users').doc(uid).delete();
    }
    catch (e){
      print('error deleting doc: $e');
    }
  }

  Future<void> updateSteps(int newSteps) async{
    try{
      //int totalSteps = currentSteps + newSteps;
      await _firestore.collection('users').doc(uid).update({'steps': newSteps});
    } catch (e){
      print('Error while updating steps: $e');
    }
  }

  Future<int> getSteps() async{
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      Map <String, dynamic> data = doc.data() as Map<String, dynamic>;
      int currentSteps = data['steps'];
      return currentSteps;
    }
    catch (e){
      print('Error while get steps: $e');
      return 0;
    }
  }

  Future<void> updatePoints() async {
    _points = points + 10;
    _firestore.collection("users").doc(uid).update({"points": _points});
    notifyListeners();
  }

  Future<void> buyItem(int points, Shop shop) async {
    _points = points;
    final buyLog = BoughtItem(
        date: dateFormat.format(DateTime.now()),
        itemId: shop.id,
        itemName: shop.name,
        itemCost: shop.cost);
    _allBoughtItems.add(buyLog);
    _firestore.collection("users").doc(uid).update({"points": points});
    _firestore.collection("users").doc(uid).update({
      "buyLog": [
        ..._allBoughtItems.map((e) => e.toMap()).toList(),
      ]
    });
    notifyListeners();
  }
}
