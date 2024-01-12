import 'package:app/pages/widgets/boldLabel.dart';
import 'package:app/pages/widgets/reservationTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './widgets/tables.dart';
import 'add.dart';

class Reservation {
  int? tableNumber;
  String? timeSlot;
  String? phoneNumber;
  String? notes;
  String? name;
  int? people;
  bool isSelected = false;
  int? attended;
  String? timeStamp;

  String? docId;

  DateTime get reservationTime => DateFormat('hh:mm a').parse(timeSlot!);

  Reservation(
      {this.tableNumber,
      this.timeSlot,
      this.name,
      this.phoneNumber,
      this.notes,
      this.people,
      this.attended,
      this.docId,
      this.timeStamp,
      required this.isSelected});
}

class TimeSlot {
  String time;
  List<Reservation> reservations;

  TimeSlot({required this.time, List<Reservation>? reservations})
      : reservations = reservations ?? [];
}

List<TimeSlot> generateTimeSlots() {
  List<TimeSlot> slots = [];

  // Morning slots
  for (int i = 0; i <= 5; i++) {
    String timeString = DateFormat('hh:mm a')
        .format(DateTime(0, 0, 0, 12).add(Duration(minutes: 30 * i)));
    slots.add(TimeSlot(time: timeString));
  }

  // Evening slots
  for (int i = 0; i <= 8; i++) {
    String timeString = DateFormat('hh:mm a')
        .format(DateTime(0, 0, 0, 17).add(Duration(minutes: 30 * i)));
    slots.add(TimeSlot(time: timeString));
  }

  // Add 'Other' slot
  slots.add(TimeSlot(time: 'Other'));

  return slots;
}

String getNearestPrecedingTimeSlot(
    String reservationTime, List<TimeSlot> slots) {
  DateTime reservationDateTime = DateFormat('hh:mm a').parse(reservationTime);
  //String nearestSlot = slots.first.time; // Default to the first slot

  for (var slot in slots) {
    if (slot.time == "Other") continue;

    DateTime slotStartTime = DateFormat('hh:mm a').parse(slot.time);
    DateTime slotEndTime = slotStartTime.add(Duration(minutes: 30));

    if (reservationDateTime.isAtSameMomentAs(slotStartTime) ||
        (reservationDateTime.isAfter(slotStartTime) &&
            reservationDateTime.isBefore(slotEndTime))) {
      return slot.time;
    }
  }

  return 'Other';
}

class ReservationList extends StatefulWidget {
  final Function onDeleteSelected;
  final Function(bool) onSelectionChanged;
  final Function(List<String>) onSelectedReservations;
  final Function(DateTime) onDateChanged;
  final DateTime selectedDate;
  //final DateTime onSelectedDateChanged;

  const ReservationList(
      {Key? key,
      //required this.onSelectedDateChanged,
      required this.selectedDate,
      required this.onSelectionChanged,
      required this.onDeleteSelected,
      required this.onSelectedReservations,
      required this.onDateChanged})
      : super(key: key);

  @override
  _ReservationListState createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  DateTime selectedDate = DateTime.now();
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('reservations');

  Map<String, bool> checkedReservations = {};
  List<TimeSlot> currentSlots = [];

  Future<void> addReservation(String timeSlot) async {
    await collection.add({
      'people_class': '99',
      'table_class': '99',
      'name_class': 'Specify Name',
      'phNumber_class': 0123456789,
      'notes_class': 'Specify Notes',
      'time_class': timeSlot,
      'attended_class': 0,
      'timeStamp_class':
          '${DateFormat('yyyy-MM-dd').format(selectedDate)}T${timeSlot.split(' ')[0]}:00' // example format
    });
  }

  @override
  void initState() {
    super.initState();
    widget
        .onDateChanged(selectedDate); // Inform parent widget about initial date
    _fetchAndUpdateData(selectedDate);
  }

  @override
  void didUpdateWidget(ReservationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        selectedDate = widget.selectedDate;
      });
      // any additional logic if needed
      _fetchAndUpdateData(selectedDate);
    }
  }

  Future<void> _fetchAndUpdateData(DateTime date) async {
    // Fetch data for 'selectedDate' asynchronously
    var newSlots = await _getSlotsForSelectedDate(selectedDate);
    if (!mounted) return;

    setState(() {
      currentSlots = newSlots; // Update the state with new data
    });
  }

  Future<List<TimeSlot>> _getSlotsForSelectedDate(DateTime date) async {
    // Your logic to fetch slots data for the given date
    // This should return a List<TimeSlot>
    // For now, let's use the generateTimeSlots function
    return generateTimeSlots(); // Replace this with your actual data fetching logic
  }

  void _showAddReservationSheet(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);

        return Builder(
          builder: (BuildContext context) {
            return Theme(
              data: theme, // Apply the fetched theme
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight),
                child: AddPage(selectedDate: selectedDate),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  void _onReservationSelected(bool selected, String docId) {
    setState(() {
      checkedReservations[docId] = selected;
      widget.onSelectionChanged(checkedReservations.containsValue(true));
      var selectedReservationIds = checkedReservations.keys
          .where((id) => checkedReservations[id] == true)
          .toList();
      widget
          .onSelectedReservations(selectedReservationIds); // Call the callback
    });
  }

  void _changeDate(bool increment) {
    setState(() {
      selectedDate = increment
          ? selectedDate.add(Duration(days: 1))
          : selectedDate.subtract(Duration(days: 1));
    });
    widget.onDateChanged(selectedDate); // Notify the parent widget
  }

  @override
  Widget build(BuildContext context) {
    List<TimeSlot> slots = generateTimeSlots();

    // Get screen width
    double screenWidth = MediaQuery.of(context).size.width * 0.95;
    double widthForFirstTwoColumns =
        screenWidth * 0.05; // 10% for the first two columns
    double widthForLastTwoColumns =
        screenWidth * 0.10; // 20% for the last two columns
    double remainingWidth =
        screenWidth - 2 * widthForFirstTwoColumns - 2 * widthForLastTwoColumns;
    double widthForMiddleThreeColumns =
        remainingWidth / 3; // Split the remaining width

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // ... [The rest of your code remains unchanged]
          // ElevatedButton(
          //   onPressed: _deleteSelectedReservations,
          //   child: Text('Delete Selected Reservations'),
          // ),
          // ElevatedButton(
          //   onPressed: _showAddReservationSheet,
          //   child: Text('Add Reservation'),
          // ),
          FutureBuilder<Map<String, Map<int, bool>>>(
            future: _getReservedTablesForDate(selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                //return CircularProgressIndicator();
                //return Container();
              }
              if (snapshot.hasError) {
                // Display the error
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                // Return an empty ReservationTableHeader or any other widget you see fit
                return ReservationTableHeader(
                  afternoonReservations: const {},
                  nightReservations: const {},
                  selectedDate: selectedDate,
                );
              }
              var afternoonReservations = snapshot.data!['afternoon']!;
              var nightReservations = snapshot.data!['night']!;
              return ReservationTableHeader(
                afternoonReservations: afternoonReservations,
                nightReservations: nightReservations,
                selectedDate: selectedDate,
              );
            },
          ),
          GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              // Check the direction of the drag
              if (details.primaryVelocity! > 0) {
                // User swiped from left to right
                _changeDate(false); // Decrement date
              } else if (details.primaryVelocity! < 0) {
                // User swiped from right to left
                _changeDate(true); // Increment date
              }
            },
            child: Container(
              color: Colors
                  .transparent, // You can make this transparent or any color of your choice
              width: MediaQuery.of(context)
                  .size
                  .width, // Expanding to the full width of the screen
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () => _changeDate(false),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () => _changeDate(true),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: collection
                  .where('timeStamp_class',
                      isGreaterThanOrEqualTo:
                          '${DateFormat('yyyy-MM-dd').format(selectedDate)}T00:00:00')
                  .where('timeStamp_class',
                      isLessThan: DateFormat('yyyy-MM-dd')
                              .format(selectedDate.add(Duration(days: 1))) +
                          'T00:00:00')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No reservations found for this date.');
                }

                List<TimeSlot> slots = generateTimeSlots();

                for (var doc in snapshot.data!.docs) {
                  var reservationData = doc.data() as Map<String, dynamic>;
                  var reservation = Reservation(
                    tableNumber: reservationData['table_class'],
                    timeSlot: reservationData['time_class'],
                    name: reservationData['name_class'],
                    phoneNumber: reservationData['phNumber_class'],
                    notes: reservationData['notes_class'],
                    attended: reservationData['attended_class'],
                    people: reservationData['people_class'],
                    timeStamp: reservationData['timeStamp_class'],
                    docId: doc.id,
                    isSelected: checkedReservations[doc.id] ?? false,
                  );

                  String nearestSlotTIme =
                      getNearestPrecedingTimeSlot(reservation.timeSlot!, slots);

                  var slotIndex =
                      slots.indexWhere((s) => s.time == nearestSlotTIme);

                  if (slotIndex != -1) {
                    print(
                        "Adding reservation to slot: ${slots[slotIndex].time}");
                    slots[slotIndex].reservations.add(reservation);
                  } else {
                    print(
                        "No matching slot found for reservation time: ${reservation.timeSlot}");
                    var otherSlotIndex =
                        slots.indexWhere((s) => s.time == 'Other');
                    slots[otherSlotIndex].reservations.add(reservation);
                  }

                  // After populating the reservations, sort them within each slot
                  for (var slot in slots) {
                    slot.reservations.sort((a, b) =>
                        a.reservationTime.compareTo(b.reservationTime));
                  }
                }

                return ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    TimeSlot slot = slots[index];
                    return ListTile(
                      title: Text(slot.time, style: TextStyle(fontSize: 20.0)),
                      subtitle: Column(
                        children: slot.reservations.map((reservation) {
                          return Dismissible(
                            key: Key(reservation.hashCode.toString()),
                            onDismissed: (direction) {
                              // Handle swipe to left
                              if (direction == DismissDirection.endToStart) {
                                setState(() {
                                  reservation.attended =
                                      reservation.attended == 1
                                          ? 0
                                          : 1; // Update attended status
                                  collection.doc(reservation.docId).update(
                                      {'attended_class': reservation.attended});
                                  // Update in Firestore as needed
                                });
                              }
                            },
                            background: Container(
                                color: Colors
                                    .transparent), // Swipe background color
                            child: Card(
                              color: reservation.attended == 1
                                  ? Colors.lightGreen[100]
                                  : Colors.red[50],
                              child: Row(
                                children: [
                                  ReservationTile(reservation: reservation),
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () {
                                        print("people : ${reservation.people}");

                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            ThemeData theme = Theme.of(context);

                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Theme(
                                                  data:
                                                      theme, // Apply the fetched theme
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .padding
                                                                .top +
                                                            kToolbarHeight),
                                                    child: AddPage(
                                                        existingReservation:
                                                            reservation,
                                                        selectedDate:
                                                            selectedDate),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ).then((_) {
                                          setState(() {});
                                        });
                                      },
                                      //existingReservation: reservation,
                                      // onTap: () {
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => AddPage(existingReservation: reservation),
                                      //     ),
                                      //   ).then((_) {
                                      //     setState(() {}); // Refresh the list after editing
                                      //   });
                                      // },

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Time: ',
                                              text: '${reservation.timeSlot}',
                                            ),
                                          ),
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Name: ',
                                              text: '${reservation.name}',
                                            ),
                                          ),
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Phone No: ',
                                              text:
                                                  '${reservation.phoneNumber}',
                                            ),
                                          ),
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Notes: ',
                                              text: '${reservation.notes}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Checkbox(
                                    value: reservation.isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        reservation.isSelected = value!;
                                        checkedReservations[
                                            reservation.docId!] = value;
                                        _onReservationSelected(
                                            value!, reservation.docId!);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      onTap: () {
                        _showAddReservationSheet(selectedDate);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _takeAttendance(String documentId) {
    collection.doc(documentId).update({'attended_class': 1});
  }

  void _deleteSelectedReservations() {
    checkedReservations.forEach((docId, isSelected) {
      if (isSelected) {
        collection.doc(docId).delete();
      }
    });
    setState(() {
      checkedReservations.clear();
    });
    widget.onDeleteSelected();
  }

  Future<Map<String, Map<int, bool>>> _getReservedTablesForDate(
      DateTime date) async {
    Map<int, bool> afternoonReservations = {};
    Map<int, bool> nightReservations = {};

    // Format the date for querying Firestore
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Fetch reservations for the selected date
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('reservations')
        .where('timeStamp_class',
            isGreaterThanOrEqualTo: formattedDate + "T00:00:00")
        .where('timeStamp_class',
            isLessThanOrEqualTo: formattedDate + "T23:59:59")
        .get();

    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int tableNumber = data['table_class'];
      String timeSlot = data['time_class'];
      String timeStamp = data['timeStamp_class'];
      DateTime reservationDateTime =
          _parseReservationDateTime(timeStamp, timeSlot);

      // Categorize reservations into afternoon and night
      if (reservationDateTime.hour >= 12 && reservationDateTime.hour < 14 ||
          (reservationDateTime.hour == 14 && reservationDateTime.minute < 30)) {
        // 12:00 PM to 2:30 PM
        afternoonReservations[tableNumber] = true;
      } else if (reservationDateTime.hour >= 17 &&
              reservationDateTime.hour < 21 ||
          (reservationDateTime.hour == 21 && reservationDateTime.minute < 30)) {
        // 5:00 PM to 9:30 PM
        nightReservations[tableNumber] = true;
      }
    }

    return {
      'afternoon': afternoonReservations,
      'night': nightReservations,
    };
  }

  DateTime _parseReservationDateTime(String timeStamp, String timeSlot) {
    // Parse the date part
    DateTime datePart = DateFormat('yyyy-MM-dd').parse(timeStamp.split('T')[0]);

    // Convert the 12-hour format timeSlot to 24-hour format for parsing
    TimeOfDay parsedTime = _parseTimeSlot(timeSlot);
    return DateTime(datePart.year, datePart.month, datePart.day,
        parsedTime.hour, parsedTime.minute);
  }

  TimeOfDay _parseTimeSlot(String timeSlot) {
    DateTime tempDate = DateFormat('hh:mm a').parse(timeSlot);
    return TimeOfDay(hour: tempDate.hour, minute: tempDate.minute);
  }

  bool isTimeInRange(String timeSlot, String start, String end) {
    DateTime slotTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(timeSlot);
    DateTime startTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(start);
    DateTime endTime = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(end);
    return slotTime.isAfter(startTime) && slotTime.isBefore(endTime);
  }
}
