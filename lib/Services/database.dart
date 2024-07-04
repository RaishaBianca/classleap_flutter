import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  static DatabaseService? _instance;

  DatabaseService._({required this.uid});
  static DatabaseService create({required String uid}) {
    return DatabaseService._(uid: uid);
  }

  static DatabaseService getInstance({required String uid}) {
    _instance ??= DatabaseService._(uid: uid);
    return _instance!;
  }

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference todoListCollection = FirebaseFirestore.instance.collection('todoLists');

  // In lib/Services/database.dart
  Future updateUserData(String name, String email, String nim) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot update user data.");
    }

    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'nim': nim,
    });
  }

  Future updateUserProfile(String name, String profilePictureUrl) async {
    return await userCollection.doc(uid).update({
      'name': name,
      'profilePictureUrl': profilePictureUrl,
    });
  }

  Future fetchCategories () async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot fetch categories.");
    }
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('todoLists')
        .get();

    List<String> categories = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
      if (!categories.contains(item['categories'])) {
        categories.add(item['categories']);
      }
    }
    return categories;
  }

  Future fetchAllToDoItemsCategories({String? category}) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot fetch to-do list items.");
    }
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('todoLists')
        .where('categories', isEqualTo: category)
        .get();

    List<Map<String, dynamic>> toDoItems = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
      item['id'] = doc.id; // Optionally include the document ID
      toDoItems.add(item);
    }
    print(toDoItems);
    return toDoItems;
  }

  Future addEvents(String title, DateTime date, String description) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot add event.");
    }

    print('addevent date $date');
    Timestamp dateTimestamp = Timestamp.fromDate(date);
    print('addevent datetime $dateTimestamp');

    DocumentReference docRef = await userCollection
        .doc(uid)
        .collection('events')
        .add({
      'title': title,
      'date': dateTimestamp,
      'description': description,
    });
    return docRef.id; // You can return this ID to use elsewhere
  }

  Future deleteEvents (String eventId) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot delete event.");
    }
    await userCollection
        .doc(uid)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  Future fetchEvents() async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot fetch events.");
    }
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('events')
        .get();

    List<Map<String, dynamic>> events = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
      event['id'] = doc.id; // Optionally include the document ID
      events.add(event);
    }
    return events;
  }

  // get user data
  Future getUserData() async {
    return await userCollection.doc(uid).get();
  }

  //create to do list
  Future addToDoListItem(String title, DateTime deadline, String categories, bool isFinished) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot add to-do list item.");
    }

    Timestamp deadlineTimestamp = Timestamp.fromDate(deadline);
    DocumentReference docRef = await userCollection
        .doc(uid)
        .collection('todoLists')
        .add({
      'title': title,
      'deadline': deadlineTimestamp,
      'categories': categories,
      'isFinished': isFinished,
    });
    // The docRef.id contains the ID of the newly created to-do list item
    return docRef.id; // You can return this ID to use elsewhere
  }

  Future updateToDoListItemStatus(String toDoListId, bool isFinished) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot update to-do list item.");
    }
    await userCollection
        .doc(uid)
        .collection('todoLists')
        .doc(toDoListId) // Use the to-do list item's ID here
        .update({
      'isFinished': isFinished,
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllToDoItems() async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot fetch to-do list items.");
    }
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('todoLists')
        .get();

    List<Map<String, dynamic>> toDoItems = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
      item['id'] = doc.id; // Optionally include the document ID
      toDoItems.add(item);
    }
    return toDoItems;
  }

  Future deleteToDoListItem(String toDoListId) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot delete to-do list item.");
    }
    await userCollection
        .doc(uid)
        .collection('todoLists')
        .doc(toDoListId) // Use the to-do list item's ID here
        .delete();
  }

  Future updateToDoListItem (String toDoListId, String title, DateTime deadline, String categories, bool isFinished) async {
    if (uid == null) {
      throw Exception("User UID is null. Cannot update to-do list item.");
    }
    Timestamp deadlineTimestamp = Timestamp.fromDate(deadline);
    await userCollection
        .doc(uid)
        .collection('todoLists')
        .doc(toDoListId) // Use the to-do list item's ID here
        .update({
      'title': title,
      'deadline': deadlineTimestamp,
      'categories': categories,
      'isFinished': isFinished,
    });
  }

}