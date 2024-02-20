import 'dart:math';
import 'package:app/pages/add.dart';
import 'package:app/pages/reservation.dart';
import 'package:flutter/material.dart';

class ReservationTableHeader extends StatefulWidget {
  final int totalTables;
  final Map<int, TableReservationInfo> afternoonReservations;
  final Map<int, TableReservationInfo> nightReservations;
  final DateTime selectedDate;

  ReservationTableHeader({
    Key? key,
    this.totalTables = 22,
    required this.afternoonReservations,
    required this.nightReservations,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _ReservationTableHeaderState createState() => _ReservationTableHeaderState();
}

class _ReservationTableHeaderState extends State<ReservationTableHeader> {
  int? selectedTable;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double cellSize = 60; // Size of the square cell
    double cellMargin = 0.66; // Margin around each cell
    double totalCellsWidth = (cellSize + cellMargin * 2) * widget.totalTables;

    double screenWidth = MediaQuery.of(context).size.width;
    // Container width is the larger of the total cells width or the screen width
    double containerWidth = screenWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: cellSize,
        width: containerWidth, // Updated width
        child: ListView.builder(
          // Always scrollable physics
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: widget.totalTables,
          itemBuilder: (context, index) {
            var afternoonInfo = widget.afternoonReservations[index + 1];
            var nightInfo = widget.nightReservations[index + 1];

            /// Determine colors based on reservation count and attendance
            Color afternoonColor = (afternoonInfo != null)
                ? determineColor(afternoonInfo)
                : Colors.transparent;
            Color nightColor = (nightInfo != null)
                ? determineColor(nightInfo)
                : Colors.transparent;

            bool isAfternoonReserved = afternoonInfo?.isReserved ?? false;
            int afternoonAttended = afternoonInfo?.attended ?? 0;

            bool isNightReserved = nightInfo?.isReserved ?? false;
            int nightAttended = nightInfo?.attended ?? 0;
            //print("Table: ${index + 1}, Afternoon isReserved: $isAfternoonReserved, Night isReserved: $isNightReserved, afternoon attended: $afternoonAttended, night attended: $nightAttended");

            return Container(
              height: cellSize,
              width: cellSize,
              margin: EdgeInsets.all(cellMargin),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set border color
                  width: 1.0, // Set border width
                ),
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: cellSize / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAfternoonReserved
                            ? Colors.orange.shade200
                            : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: cellSize / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isNightReserved
                            ? Colors.blue.shade200
                            : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    onPressed: () => _onButtonPressed(index),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color determineColor(TableReservationInfo info) {
    try {
      if (info == null) return Colors.transparent;
      //print('Determining color for: ${info.toString()}');
      if (info.numberOfReservations > 1 && !info.allAttended) {
        //print('Returning darker color');
        return const Color.fromARGB(255, 255, 60, 0); // Darker color
      } else if (info.isReserved) {
        //print('Returning original color');
        return Colors.orange.shade200; // Original color
      }
      return Colors.transparent;
    } catch (e) {
      //print('Error in determineColor: $e');
      return Colors.transparent;
    }
  }

  void _onButtonPressed(int index) {
    setState(() => _isPressed = !_isPressed);
    _showAddReservationSheet(context, index + 1);

    // Perform action...
  }

  void _showAddReservationSheet(BuildContext context, int tableNumber) {
    print('Opening AddPage with selectedDate: ${widget.selectedDate}');

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
                child: AddPage(
                    selectedDate: widget.selectedDate,
                    tableNumber: tableNumber),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }
}
//selectedDate: widget.selectedDate, tableNumber: tableNumber);
      