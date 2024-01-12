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
      /*builder: (BuildContext context) {
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
      },*/
      builder: (BuildContext context) {
        return AddPage(selectedDate: _currentSelectedDateNotifier.value);
      },
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
        title: const Text('Reservations | ver 1.2.1'),
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
