import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class Reservation
{

  int? people_class;
  int? table_class;
  String? name_class;
  String? phNumber_class;
  String? notes_class;
  String? time_class;
  int? attended_class;
  String? timeStamp_class;

  String? timeSlot;
  bool isSelected = false;
  String? docId;

  DateTime get reservationTime => DateFormat('hh:mm a').parse(timeSlot!);

  Reservation(
      {this.people_class, this.table_class, this.name_class, this.phNumber_class, this.notes_class, this.time_class, this.attended_class, this.timeStamp_class, this.timeSlot, required this.isSelected, this.docId});

  Reservation.fromJson(Map<String, dynamic> json, this.docId)
      :
        people_class = json['people_class'],
        table_class = json['table_class'],
        name_class = json['name_class'],
        phNumber_class = json['phNumber_class'],
        notes_class = json['notes_class'],
        time_class = json['time_class'],
        attended_class = json['attended_class'],
        timeStamp_class = json['timeStamp_class'];

  Map<String, dynamic> toJson() =>
      {
        'people_class': people_class,
        'table_class': table_class,
        'name_class' : name_class,
        'phNumber_class': phNumber_class,
        'notes_class' : notes_class,
        'time_class': time_class,
        'attended_class' : attended_class,
        'timeStamp_class' : timeStamp_class
      };
}

class ReservationModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Reservation> items = [];


  Reservation? get(String? docId)
  {
    if (docId == null) return null;
    return items.firstWhere((reservation) => reservation.docId == docId);
  }

  //added this
  CollectionReference reservationsCollection = FirebaseFirestore.instance.collection('reservations');

  //added this
  bool loading = false;

  ReservationModel()
  {

    fetch(); //this line won't compile until the next step

  }

  /*void add(Feed item) {
    items.add(item);
    update();
  }*/

  Future add(Reservation item) async
  {

    loading = true;
    update();

    await reservationsCollection.add(item.toJson());

    print('Item added. New length: ${items.length}');
    //refresh the db
    await fetch();
  }

  Future<void> addItem(Reservation item) async {
    loading = true;
    update();

    DocumentReference docRef = await reservationsCollection.add(item.toJson());

    item.docId = docRef.id; // Set the id to the newly created document's id
    items.insert(0, item); // Insert the new item at the beginning of the list

    print('Item added. New length: ${items.length}');

    loading = false;
    update();
  }


  Future updateItem(String docId, Reservation item) async
  {
    loading = true;
    update();

    await reservationsCollection.doc(docId).set(item.toJson());

    //refresh the db
    await fetch();
  }

  Future delete(String docId) async
  {
    loading = true;
    update();

    await reservationsCollection.doc(docId).delete();

    //refresh the db
    await fetch();
  }

  // This call tells the widgets that are listening to this model to rebuild.
  void update()
  {
    print('Calling notifyListeners...');
    notifyListeners();
    print('Finished calling notifyListeners...');

  }

  Future fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //try {
    var querySnapshot = await reservationsCollection.orderBy("timeStamp_class", descending: true).get();

    //iterate over the feeds and add them to the list
    for (var doc in querySnapshot.docs) {
      var reservation = Reservation.fromJson(doc.data()! as Map<String, dynamic>, doc.id);//note not using the add(Feed item) function, because we don't want to add them to the db
      items.add(reservation);
      print('adding reservation item : ${reservation.timeStamp_class}');
    }
    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying

    //await Future.delayed(const Duration(seconds: 2)); // artificial delay
    //} catch (error) {
    //print("Error fetching data: $error");
    // handle error according to your needs, e.g. show a message to the user
    //} finally {
    loading = false;
    update();
    //}
  }

  // listen to the itemsStream() in your _MyHomePageState and update the UI whenever there's new data.
  Stream<List<Reservation>> itemsStream() {
    return reservationsCollection.orderBy("timeStamp_class").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<ReservationModel> get feedModelStream {
    return reservationsCollection.orderBy("timeStamp_class").snapshots().map((snapshot) {
      // clear the current list of items
      items.clear();

      // add all the new items
      items.addAll(snapshot.docs.map((doc) {
        return Reservation.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      }).toList());

      // notify listeners that items have changed
      notifyListeners();

      // return this instance of FeedModel
      return this;
    });
  }

  Future<void> refreshFeeds() async {
    // Add your refresh code here.
    // For example, you might make an API call to get updated data.
    // For now we'll just wait for a second.
    //await Future.delayed(Duration(seconds: 1));

    // Fetch the feeds again here
    fetch();

    // Notify listeners to rebuild UI
    notifyListeners();
  }

}