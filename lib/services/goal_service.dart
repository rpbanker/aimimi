import 'package:aimimi/models/goal.dart';
import 'package:aimimi/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalService {
  final String uid;
  final String goalID;

  GoalService({this.uid, this.goalID});

  final CollectionReference<Map<String, dynamic>> goalCollection =
      FirebaseFirestore.instance.collection("goals");

  final CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("users");

  // Get all shared goals for SharesView
  Future<List<SharedGoal>> _createSharedGoals(
          QuerySnapshot<Map<String, dynamic>> querySnapshot) =>
      Future.wait(querySnapshot.docs.map<Future<SharedGoal>>(
          (DocumentSnapshot<Map<String, dynamic>> sharedGoal) async {
        return SharedGoal(
          goalID: sharedGoal.id,
          title: sharedGoal.data()["title"],
          category: sharedGoal.data()["category"],
          period: sharedGoal.data()["period"],
          frequency: sharedGoal.data()["frequency"],
          timespan: sharedGoal.data()["timespan"],
          publicity: sharedGoal.data()["publicity"],
          description: sharedGoal.data()["description"],
          createdBy: CreatedBy(
            uid: sharedGoal.data()["createdBy"]["uid"],
            username: sharedGoal.data()["createdBy"]["username"],
          ),
          createAt: sharedGoal.data()["createdAt"].toDate(),
          users: await goalCollection
              .doc(sharedGoal.id)
              .collection("users")
              .get()
              .then((QuerySnapshot querySnapshot) => querySnapshot.docs
                  .map((DocumentSnapshot user) => user)
                  .toList()),
        );
      }).toList());

  Stream<List<SharedGoal>> get sharedGoals {
    return goalCollection
        .where("publicity", isEqualTo: true)
        .snapshots()
        .asyncMap(_createSharedGoals);
  }

  // Get a shared goal for SharedGoalView
  Future<SharedGoal> _createSharedGoal(
          DocumentSnapshot<Map<String, dynamic>> sharedGoal) async =>
      SharedGoal(
        title: sharedGoal.data()["title"],
        category: sharedGoal.data()["category"],
        period: sharedGoal.data()["period"],
        frequency: sharedGoal.data()["frequency"],
        timespan: sharedGoal.data()["timespan"],
        publicity: sharedGoal.data()["publicity"],
        description: sharedGoal.data()["description"],
        createdBy: CreatedBy(
          uid: sharedGoal.data()["createdBy"]["uid"],
          username: sharedGoal.data()["createdBy"]["username"],
        ),
        createAt: sharedGoal.data()["createdAt"].toDate(),
        users: await goalCollection
            .doc(sharedGoal.id)
            .collection("users")
            .get()
            .then((QuerySnapshot querySnapshot) => querySnapshot.docs
                .map((DocumentSnapshot user) => user)
                .toList()),
      );

  Stream<SharedGoal> get sharedGoal {
    return goalCollection.doc(goalID).snapshots().asyncMap(_createSharedGoal);
  }

  // Get all goals for that user
  List<UserGoal> _createUserGoals(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    return querySnapshot.docs
        .map<UserGoal>(
            (DocumentSnapshot<Map<String, dynamic>> userGoal) => (UserGoal(
                  accuracy: userGoal.data()["accuracy"].toDouble(),
                  checkIn: userGoal.data()["checkIn"],
                  checkInSuccess: userGoal.data()["checkInSuccess"],
                  checkedIn: userGoal.data()["checkedIn"],
                  dayPassed: userGoal.data()["dayPassed"],
                  goalID: userGoal.id,
                  goal: Goal(
                    title: userGoal.data()["goal"]["title"],
                    category: userGoal.data()["goal"]["category"],
                    period: userGoal.data()["goal"]["period"],
                    frequency: userGoal.data()["goal"]["frequency"],
                    timespan: userGoal.data()["goal"]["timespan"],
                    publicity: userGoal.data()["goal"]["publicity"],
                    description: userGoal.data()["goal"]["description"],
                  ),
                )))
        .toList();
  }

  Stream<List<UserGoal>> get userGoals {
    return userCollection
        .doc(uid)
        .collection("goals")
        .snapshots()
        .map(_createUserGoals);
  }

  // Add goal action
  void addGoal(title, category, description, publicity, period, frequency,
      timespan) async {
    DocumentReference doc = await goalCollection.add({
      'title': title,
      'category': category,
      'description': description,
      'publicity': publicity,
      'period': period,
      'frequency': frequency,
      'timespan': timespan,
      'createdBy': {
        'uid': FirebaseAuth.instance.currentUser.uid,
        'username': FirebaseAuth.instance.currentUser.displayName,
      },
      "createdAt": Timestamp.now(),
    });
    print(doc.id);
    await userCollection
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("goals")
        .doc(doc.id.toString())
        .set({
      "accuracy": 0,
      "checkIn": 0,
      "checkInSuccess": 0,
      "checkedIn": false,
      "dayPassed": 0,
      "goal": {
        'description': description,
        'frequency': frequency,
        'period': period,
        'publicity': publicity,
        'timespan': timespan,
        'title': title,
      },
    });
  }

  // Check in action
  Future checkInGoal(int checkIn, UserGoal selectedGoal) {
    final bool doEnoughTimes = checkIn >= selectedGoal.goal.frequency;

    if (doEnoughTimes) {
      return userCollection
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("goals")
          .doc(selectedGoal.goalID)
          .update({
        "checkIn": checkIn,
        "checkInSuccess": FieldValue.increment(1),
        "checkedIn": true,
        "dayPassed": FieldValue.increment(1)
      });
    }

    return userCollection
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("goals")
        .doc(selectedGoal.goalID)
        .update({"checkIn": checkIn});
  }

  // Join goal action
  Future joinGoal() {
    return goalCollection.doc(goalID).collection("users").doc(uid).set({
      "accuracy": 0,
      "username": FirebaseAuth.instance.currentUser.displayName,
    });
  }
}
