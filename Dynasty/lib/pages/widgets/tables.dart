import 'package:flutter/material.dart';

class ReservationTableHeader extends StatelessWidget {
  final int totalTables;
  final Map<int, bool> afternoonReservations;
  final Map<int, bool> nightReservations;

  ReservationTableHeader({
    Key? key,
    this.totalTables = 22,
    required this.afternoonReservations,
    required this.nightReservations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cellSize = 60; // Size of the square cell
    double cellMargin = 0.66; // Margin around each cell
    double totalCellsWidth = (cellSize + cellMargin * 2) * totalTables; // Total width of all cells, including margins
    double screenWidth = MediaQuery.of(context).size.width; // Get the screen width

    // Check if the total width of cells is less than the screen width
    bool cellsFillScreen = totalCellsWidth > screenWidth;

    // Calculate the padding to center the cells in the screen
    double horizontalPadding = cellsFillScreen ? 0 : (screenWidth - totalCellsWidth) / 2;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding), // Apply horizontal padding
      child: Container(
        height: cellSize, // Height to accommodate two rows
        width: cellsFillScreen ? null : totalCellsWidth, // Set the width of the container
        child: ListView.builder(
          // Setting physics to null to prevent ListView from scrolling
          physics: cellsFillScreen ? null : NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: totalTables,
          itemBuilder: (context, index) {
            bool isAfternoonReserved = afternoonReservations[index + 1] ?? false;
            bool isNightReserved = nightReservations[index + 1] ?? false;
            return Container(
              width: cellSize,
              margin: EdgeInsets.all(cellMargin),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
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
                        color: isAfternoonReserved ? Colors.orange.shade200 : Colors.transparent,
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
                    top: cellSize / 2, // Half the size of the cell
                    child: Container(
                      decoration: BoxDecoration(
                        color: isNightReserved ? Colors.blue.shade200 : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
}
