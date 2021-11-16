import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hello_me/user_aut_repository.dart';

class UserMetaDataRepository with ChangeNotifier {
  final _saved = <WordPair>{};
  String avatarFileName = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<WordPair> get saved => _saved;

  String get avatar => avatarFileName;

  void updateDataBaseForUser(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'savedWordPairs':
            _saved.map((e) => {'first': e.first, 'second': e.second}).toList()
      });
    }
  }

  void update(AuthRepository myModel) async {
    if (myModel.isAuthenticated) {
      var docSnapshot =
          await _firestore.collection('users').doc(myModel.user!.uid).get();
      if (!docSnapshot.exists) {
        await _firestore
            .collection('users')
            .doc(myModel.user!.uid)
            .set({'savedWordPairs': [], 'avatar': ''});
      }
      docSnapshot =
          await _firestore.collection('users').doc(myModel.user!.uid).get();
      final savedWordsList = docSnapshot.data()!['savedWordPairs'] ?? [];
      savedWordsList.forEach((pairJson) {
        _saved.add(WordPair(pairJson['first'], pairJson['second']));
      });
      avatarFileName = docSnapshot.data()!['avatar'] ?? '';
      updateDataBaseForUser(myModel.user);
      notifyListeners();
    }
  }

  void clearSuggestions() {
    _saved.removeAll(_saved.toList());
    notifyListeners();
  }

  void updateAvatar(User? firebaseUser, String name) async {
    var docSnapshot =
        await _firestore.collection('users').doc(firebaseUser!.uid).get();
    if (!docSnapshot.exists) {
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set({'savedWordPairs': [], 'avatar': ''});
    }
    docSnapshot =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .update({'avatar': name});
    avatarFileName = name;
    notifyListeners();
  }

  void addSuggestion(User? firebaseUser, WordPair pairToAdd) {
    _saved.add(pairToAdd);
    notifyListeners();
    updateDataBaseForUser(firebaseUser);
  }

  bool isAlreadySaved(WordPair pairToFind) {
    return _saved.contains(pairToFind);
  }

  void removeSuggestion(User? firebaseUser, WordPair pairToRemove) {
    _saved.remove(pairToRemove);
    updateDataBaseForUser(firebaseUser);
    notifyListeners();
  }
}
