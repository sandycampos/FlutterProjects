import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//objeto que vai guardar os estados de login
class UserModel extends Model {

  bool isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();

  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);

  @override
  void addListener (VoidCallback listener){
    super.addListener(listener);

    _loadCurrentUser();
  }

  //usuario atual

  void signUp({
    @required Map<String, dynamic> userData, 
    @required String pass, 
    @required VoidCallback onSuccess, 
    @required VoidCallback onFail}){
  
    isLoading = true;
    notifyListeners();

    print(userData);
    _auth.createUserWithEmailAndPassword(
      email: userData["email"],
      password: pass
    ).then((auth) async {
      firebaseUser = auth.user;

  await _saveUserData(userData);

      onSuccess();
      isLoading = false;
      notifyListeners();

      }).catchError((e){
        onFail();
        isLoading = false;
        notifyListeners();
        print(e);
      });
  }

  void signIn({
    @required String email,
    @required String pass,
    @required VoidCallback onSuccess,
    @required VoidCallback onFail}) async {

    isLoading = true;
    //estou carregando
    notifyListeners();
    //notifico que estou carregando
    
    _auth.signInWithEmailAndPassword(
      email: email, 
      password: pass
      ).then((auth) async {
        firebaseUser = auth.user;

        await _loadCurrentUser();

      onSuccess();
      isLoading = false;
      notifyListeners();
      
      }).catchError((e){
        onFail();
        isLoading = false;
        notifyListeners();
      });
  }

  void signOut() async {
    _auth.signOut();

    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  void recoverPass(String email){
    _auth.sendPasswordResetEmail(email: email);    
  }

  bool isLoggedIn(){
    return firebaseUser != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null)
      firebaseUser = await _auth.currentUser();
    if (firebaseUser != null){
      if (userData["name"] == null){
      DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get();
      userData = docUser.data;
      }
    }
    notifyListeners();
  }
}