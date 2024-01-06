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

  List<String>_selectedReservationIds = [];

  void _onSelectionChanged(bool isSelected) {
    _showDeleteButton.value = isSelected;

  }

  void _deleteReservations(List<String> selectedReservationIds) {
    final CollectionReference collection = FirebaseFirestore.instance.collection('reservations');

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
          content: const Text('Are you sure you want to delete the selected reservations?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss dialog and return false
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true); // Dismiss dialog and return true
              },
            ),
          ],
        );
      },
    ) ?? false; // If dialog is dismissed, return false

    // If deletion is confirmed, call _deleteReservations
    if (confirmDelete) {
      _deleteReservations(_selectedReservationIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Reservations '),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Navigate to calendar.dart page when implemented
            },
          )
        ],
      ),
      body: ReservationList(onSelectionChanged:_onSelectionChanged, onDeleteSelected: _deleteReservations, onSelectedReservations: _handleSelectedReservations,),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showDeleteButton,
        builder: (context, value, child) {
          return value
              ? FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete, size:36.0),
            onPressed: () {
              _showDeleteConfirmationDialog();
              // Implement deletion logic here
            },
          )
              : FloatingActionButton(
            child: const Icon(Icons.add, size:36.0),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          );
        },
      ),
    );
  }
}


