import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../reservation.dart';

class ReservationTile extends StatelessWidget {
  final Reservation reservation;
  final double cellSize;

  ReservationTile({Key? key, required this.reservation, this.cellSize = 50.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime reservationDateTime =
        DateFormat('hh:mm a').parse(reservation.timeSlot!);
    bool isAfternoonReserved =
        reservationDateTime.hour >= 12 && reservationDateTime.hour < 14 ||
            (reservationDateTime.hour == 14 && reservationDateTime.minute < 30);
    bool isNightReserved =
        reservationDateTime.hour >= 17 && reservationDateTime.hour < 21 ||
            (reservationDateTime.hour == 21 && reservationDateTime.minute < 30);

    return Container(
      width: cellSize,
      height: cellSize,
      child: Stack(
        alignment: Alignment.center, // Align text to center
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: cellSize / 2, // Half the size of the cell
            child: Container(
              decoration: BoxDecoration(
                color:
                    isAfternoonReserved ? Colors.orange.shade200 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: cellSize / 2, // Half the size of the cell
            child: Container(
              decoration: BoxDecoration(
                color: isNightReserved ? Colors.blue.shade200 : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
          ),
          Text(
            '${reservation.tableNumber}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15, // Smaller font size for the smaller tile
            ),
          ),
        ],
      ),
    );
  }
}
