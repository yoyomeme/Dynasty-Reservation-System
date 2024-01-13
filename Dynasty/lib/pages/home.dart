import 'dart:convert';
//import 'package:app/pages/widgets/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:app/pages/add.dart';
import 'package:app/pages/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ValueNotifier<bool> _showDeleteButton = ValueNotifier(false);
  final ValueNotifier<DateTime> _currentSelectedDateNotifier =
      ValueNotifier<DateTime>(DateTime.now());

  DateTime selectedDate = DateTime.now();

  List<String> _selectedReservationIds = [];

  void _showAddReservationSheet() {
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
                child:
                    AddPage(selectedDate: _currentSelectedDateNotifier.value),
              ),
            );
          },
        );
      },
      /*builder: (BuildContext context) {
        return AddPage(selectedDate: _currentSelectedDateNotifier.value);
      },*/
    ).then((_) {
      setState(() {});
    });
  }

  void _updateSelectedDate(DateTime newDate) {
    _currentSelectedDateNotifier.value = newDate;
  }

  void _onSelectionChanged(bool isSelected) {
    _showDeleteButton.value = isSelected;
  }

  void _deleteReservations(List<String> selectedReservationIds) {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('reservations');

    for (String docId in selectedReservationIds) {
      collection.doc(docId).delete(); // Delete each selected reservation
    }

    setState(() {
      // Clear the selected reservations state, or perform any other state updates
      _showDeleteButton.value = false;

      _selectedReservationIds.clear();
    });

    // Optional: Perform any additional actions after deletion, like refreshing the list
  }

  void _handleSelectedReservations(List<String> selectedReservationIds) {
    // Store or use the selectedReservationIds as needed
    // For example, update a state variable
    setState(() {
      _selectedReservationIds = selectedReservationIds;
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    print("Delete button xxxxx");
    // Show dialog and wait for user response
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                  'Are you sure you want to delete the selected reservations?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Dismiss dialog and return false
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Dismiss dialog and return true
                  },
                ),
              ],
            );
          },
        ) ??
        false; // If dialog is dismissed, return false

    // If deletion is confirmed, call _deleteReservations
    if (confirmDelete) {
      _deleteReservations(_selectedReservationIds);
    }
  }

  Future<List<DateTime>> fetchPublicHolidays(
      int year, String countryCode) async {
    var apiKey = 'bl77xGdg5Honsc9j4F95sPd8NF11saIQ';
    var url = Uri.parse(
        'https://calendarific.com/api/v2/holidays?&api_key=$apiKey&country=$countryCode&year=$year');

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Parse the data to extract public holidays
      // This depends on the structure of Calendarific's response
      List<DateTime> holidays = [];
      for (var holiday in data['response']['holidays']) {
        DateTime date = DateTime.parse(holiday['date']['iso']);
        holidays.add(date);
      }
      return holidays;
    } else {
      throw Exception('Failed to load holidays');
    }
  }
/*
  Future<void> _selectDateNum(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: CustomCalendar(
            initialDate: _currentSelectedDateNotifier.value,
            onDateSelected: (DateTime selectedDate) {
              print("Date selected from calendar: $selectedDate");
              Navigator.of(context).pop(selectedDate);
            },
          ),
        );
      },
    );

    if (picked != null && picked != _currentSelectedDateNotifier.value) {
      print("New date picked: $picked");
      setState(() {
        _currentSelectedDateNotifier.value = picked;
      });
    }
  }*/

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentSelectedDateNotifier.value,
      firstDate: DateTime(2016),
      lastDate: DateTime(2033),
    );
    if (picked != null && picked != _currentSelectedDateNotifier.value) {
      //_updateSelectedDate(picked);
      setState(() {
        selectedDate = picked; // Update the date and trigger a rebuild
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: RichText(
          text: const TextSpan(
            // Default text style
            children: <TextSpan>[
              TextSpan(
                  text: 'Reservations',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 25,
                  )), // Default AppBar title size
              // Smaller size for the separator
              TextSpan(
                  text: ' (ver 1.2.2)',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.black)),

              /// Smaller size for version
            ],
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              // Navigate to calendar.dart page when implemented
              _selectDate(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min, // Use min to fit the content
              children: <Widget>[
                Icon(Icons.calendar_today, size: 30), // Calendar icon
                Padding(
                  padding:
                      EdgeInsets.only(left: 8), // Space between icon and text
                  child: Text('Calendar'), // Your text next to the icon
                ),
              ],
            ),
          ),
          SizedBox(
              width: 16), // Optional: adds some space to the right of the item
        ],
      ),
      body: ReservationList(
        onSelectionChanged: _onSelectionChanged,
        onDeleteSelected: _deleteReservations,
        onSelectedReservations: _handleSelectedReservations,
        onDateChanged: _updateSelectedDate,

        //selectedDate: _currentSelectedDateNotifier.value,
        selectedDate: selectedDate,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.1),
          child: ValueListenableBuilder<bool>(
            valueListenable: _showDeleteButton,
            builder: (context, value, child) {
              return value
                  ? FloatingActionButton.extended(
                      backgroundColor: Colors.red,
                      icon: const Icon(Icons.delete, size: 36.0),
                      label: const Text('Delete Item'),
                      onPressed: _showDeleteConfirmationDialog,
                    )
                  : FloatingActionButton.extended(
                      icon: const Icon(Icons.add, size: 36.0),
                      label: const Text('Add Item'),
                      onPressed: _showAddReservationSheet,
                    );
            },
          ),
        ),
      ),
    );
  }
}
