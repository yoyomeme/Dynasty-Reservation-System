import 'package:app/pages/widgets/boldLabel.dart';
import 'package:app/pages/widgets/reservationTile.dart';
import 'package:app/pages/widgets/utils.dart';
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

class TableReservationInfo {
  bool isReserved;
  int attended;
  int numberOfReservations; // Add this
  bool allAttended; // Add this

  TableReservationInfo(
      {this.isReserved = false,
      this.attended = 0,
      this.numberOfReservations = 0,
      this.allAttended = true});

  @override
  String toString() {
    return 'TableReservationInfo(isReserved: $isReserved, attended: $attended, numberOfReservations: $numberOfReservations, allAttended: $allAttended)';
  }
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

List<Widget> _buildReservationDetails2(
    Reservation reservation, bool isSmallScreen) {
  double fontSize =
      isSmallScreen ? 14.0 : 18.0; // Adjust font size based on screen size
  return [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldLabelWithText(
            label: '${reservation.timeSlot}',
            text: ' ',
            fontSize: fontSize,
          ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldLabelWithText(
            label: '',
            text: '${reservation.name}',
            fontSize: fontSize,
          ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldLabelWithText(
            label: '',
            text: 'People: ${reservation.people}',
            fontSize: fontSize,
          ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldLabelWithText(
            label: '',
            text: '${reservation.phoneNumber}',
            fontSize: fontSize,
          ),
        ],
      ),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldLabelWithText(
            label: '',
            text: '${reservation.notes}',
            fontSize: fontSize,
          ),
        ],
      ),
    ),
  ];
  /*return [
    BoldLabelWithText(
        label: '${reservation.timeSlot}', text: ' ', fontSize: fontSize),
    BoldLabelWithText(
        label: '', text: '${reservation.name}', fontSize: fontSize),
    BoldLabelWithText(
        label: 'People: ', text: '${reservation.people}', fontSize: fontSize),
    BoldLabelWithText(
        label: '', text: '${reservation.phoneNumber}', fontSize: fontSize),
    BoldLabelWithText(
        label: '', text: '${reservation.notes}', fontSize: fontSize),
  ];*/
}

List<Widget> _buildReservationDetails(
    Reservation reservation, bool isSmallScreen) {
  double fontSize =
      isSmallScreen ? 14.0 : 18.0; // Adjust font size based on screen size
  double borderHeight = 30; // Set the height of the border

  List<Widget> detailsWidgets = [
    '${reservation.timeSlot}',
    'Name: ${reservation.name}',
    'Ppl: ${reservation.people}',
    'Ph: ${reservation.phoneNumber}',
    'Note: ${reservation.notes}',
  ].asMap().entries.map((entry) {
    int index = entry.key;
    String detail = entry.value;

    Widget detailWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldLabelWithText(
          label: '',
          text: detail,
          fontSize: fontSize,
        ),
      ],
    );

    return Expanded(
      flex: index == 2 && isSmallScreen
          ? 0
          : 1, // Adjust flex for 'Ppl:' on small screen
      child: Container(
        width:
            index == 2 && isSmallScreen ? 55 : null, // Limit width for 'Ppl:'
        padding: EdgeInsets.symmetric(horizontal: 5),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: BoldLabelWithText(
                label: '',
                text: detail,
                fontSize: fontSize,
              ),
            ),
            // The border is now a vertical Container beside the text
            if (index != 4) // Add border to all except the last item
              Container(
                height: borderHeight,
                width: 1,
                color: Colors.black26,
              ),
          ],
        ),
      ),
    );
  }).toList();

  return detailsWidgets;
}

class _ReservationListState extends State<ReservationList> {
  DateTime selectedDate = DateTime.now();

  int totalReservations = 0;

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

  Future<int> _calculateTotalReservations(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    var querySnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('timeStamp_class',
            isGreaterThanOrEqualTo: formattedDate + "T00:00:00")
        .where('timeStamp_class',
            isLessThanOrEqualTo: formattedDate + "T23:59:59")
        .get();
    return querySnapshot.docs.length;
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetHolidays();
    widget
        .onDateChanged(selectedDate); // Inform parent widget about initial date
    _fetchAndUpdateData(selectedDate);
    _getReservedTablesForDate(selectedDate);
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
      _getReservedTablesForDate(selectedDate);
    }
  }

  Future<void> _fetchAndUpdateData(DateTime date) async {
    var newSlots = await _getSlotsForSelectedDate(selectedDate);
    if (!mounted) return;

    setState(() {
      _getReservedTablesForDate(selectedDate);
      currentSlots = newSlots;
      totalReservations = newSlots
          .map((slot) => slot.reservations.length)
          .fold(0, (a, b) => a + b);
      //print("Total Reservations: $totalReservations"); // Debug print
    });
  }

  Future<List<TimeSlot>> _getSlotsForSelectedDate(DateTime date) async {
    // Your logic to fetch slots data for the given date

    // Debugging: Print the formatted date being used in the query
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    //print("Querying for date: $formattedDate");

    // Perform the Firestore query (assuming this is how you're querying)
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('timeStamp_class', isEqualTo: formattedDate)
        .get();

    // Debugging: Print the number of documents fetched
    //print("Documents fetched: ${querySnapshot.docs.length}");

    // Process the query results
    // ...

    // Return the slots
    return generateTimeSlots(); // Replace with actual logic
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

//widget.onSelectionChanged(checkedReservations.containsValue(true));
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
    widget.onSelectionChanged(checkedReservations.containsValue(true));
    //print("Updated attended status for docId: $docId");
  }

  void _changeDate(bool increment) {
    setState(() {
      selectedDate = increment
          ? selectedDate.add(Duration(days: 1))
          : selectedDate.subtract(Duration(days: 1));
    });
    widget.onDateChanged(selectedDate); // Notify the parent widget
    _fetchAndUpdateData(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    List<TimeSlot> slots = generateTimeSlots();
    int totalReservationsForSelectedDate;
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
          // ),FutureBuilder<int>(

          FutureBuilder<Map<String, Map<int, TableReservationInfo>>>(
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
              //print("Afternoon Reservations is : ${afternoonReservations}");
              //print("nightRes Reservations is : ${nightReservations}");
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<int>(
                        future: _calculateTotalReservations(selectedDate),
                        builder: (context, snapshot) {
                          int totalReservations = snapshot.data ?? 0;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              Text(
                                "Total Reservations: $totalReservations",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

                int totalReservationsForSelectedDate =
                    snapshot.data!.docs.length;
                totalReservations = totalReservationsForSelectedDate;
                //});
                //print("Adding reservation to slot: ${totalReservations}");
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
                    //print( "Adding reservation to slot: ${slots[slotIndex].time}");
                    slots[slotIndex].reservations.add(reservation);
                  } else {
                    //print(
                    //  "No matching slot found for reservation time: ${reservation.timeSlot}");
                    var otherSlotIndex =
                        slots.indexWhere((s) => s.time == 'Other');
                    slots[otherSlotIndex].reservations.add(reservation);
                  }

                  // After populating the reservations, sort them within each slot
                  for (var slot in slots) {
                    slot.reservations.sort((a, b) =>
                        a.reservationTime.compareTo(b.reservationTime));
                  }
//////////////////////////////////
                  //int totalReservationsForSelectedDate = snapshot.data!.docs.length;

                  // Update the totalReservations state
                  //setState(() {
                }

                return ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    TimeSlot slot = slots[index];
                    bool isSmallScreen =
                        MediaQuery.of(context).size.width < 600;

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
                                  _fetchAndUpdateData(selectedDate);
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
                                  ReservationTile(
                                    reservation: reservation,
                                    cellSize: isSmallScreen ? 40 : 55,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: InkWell(
                                      onTap: () {
                                        //print("people : ${reservation.people}");

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
                                        children: _buildReservationDetails(
                                            reservation, isSmallScreen),
                                      ),
                                      /*child: Row(
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
                                              label: 'People: ',
                                              text: '${reservation.people}',
                                            ),
                                          ),
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Phone: ',
                                              text:
                                                  '${reservation.phoneNumber}',
                                            ),
                                          ),
                                          Expanded(
                                            child: BoldLabelWithText(
                                              label: 'Note: ',
                                              text: '${reservation.notes}',
                                            ),
                                          ),
                                        ],
                                      ),*/
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

  Future<List<Reservation>> fetchReservationsForDate(DateTime date) async {
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

    List<Reservation> reservations = [];
    for (var doc in query.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Parse each document into a Reservation object
      Reservation reservation = Reservation(
        tableNumber: data['table_class'],
        timeSlot: data['time_class'],
        name: data['name_class'],
        phoneNumber: data['phNumber_class'],
        notes: data['notes_class'],
        people: data['people_class'],
        attended: data['attended_class'],
        timeStamp: data['timeStamp_class'],
        isSelected: false, // Default value
        docId: doc.id,
      );

      reservations.add(reservation);
    }

    return reservations;
  }

  Future<Map<String, Map<int, TableReservationInfo>>> _getReservedTablesForDate(
      DateTime date) async {
    Map<int, TableReservationInfo> afternoonReservations = {};
    Map<int, TableReservationInfo> nightReservations = {};

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
      int attended = data['attended_class'];
      DateTime reservationDateTime = _parseReservationDateTime(
          data['timeStamp_class'], data['time_class']);

      bool isReserved = attended == 0;

      //print("Table: $tableNumber, isReserved: $isReserved, attended: $attended");

      List<Reservation> allReservations = await fetchReservationsForDate(
          selectedDate); // Fetch all reservations for the selected date
      updateTableInfo(
          afternoonReservations, nightReservations, allReservations);

      // Categorize reservations into afternoon and night
      if (reservationDateTime.hour >= 12 && reservationDateTime.hour < 17) {
        // 12:00 PM to 4:59 PM (Afternoon)
        afternoonReservations[tableNumber] =
            TableReservationInfo(isReserved: isReserved, attended: attended);
      } else if (reservationDateTime.hour >= 17) {
        // 5:00 PM onwards (Night)
        nightReservations[tableNumber] =
            TableReservationInfo(isReserved: isReserved, attended: attended);
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

  void updateTableInfo(
      Map<int, TableReservationInfo> afternoonReservations,
      Map<int, TableReservationInfo> nightReservations,
      List<Reservation> allReservations) {
    // Reset or initialize the reservation counts
    for (var tableNumber = 1; tableNumber <= 22; tableNumber++) {
      afternoonReservations[tableNumber] = TableReservationInfo();
      nightReservations[tableNumber] = TableReservationInfo();
    }

    // Iterate over each reservation and update the info
    for (var reservation in allReservations) {
      var tableNumber = reservation.tableNumber!;
      var isAfternoon = reservation.reservationTime.hour < 17;

      // Select the correct map based on the reservation time
      var infoMap = isAfternoon ? afternoonReservations : nightReservations;

      // Get the current info for the table, or create a new one if none exists
      var info = infoMap[tableNumber] ?? TableReservationInfo();

      // Update the reservation info
      info.isReserved = info.isReserved || (reservation.attended == 0);
      info.attended += (reservation.attended ?? 0);
      info.numberOfReservations++;
      info.allAttended = info.allAttended && (reservation.attended == 1);

      // Store the updated info back in the map
      infoMap[tableNumber] = info;
    }
  }
}
