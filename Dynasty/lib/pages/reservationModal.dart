import 'package:app/pages/reservation.dart';
import 'package:flutter/material.dart';

class ReservationModel extends ChangeNotifier {
  List<Reservation> reservations = [];


  void addReservation(Reservation reservation) {
    reservations.add(reservation);
    notifyListeners();
  }

  void updateReservation(Reservation updatedReservation) {
    int index = reservations.indexWhere((r) => r.docId == updatedReservation.docId);
    if (index != -1) {
      reservations[index] = updatedReservation;
      notifyListeners();
    }
  }

  void deleteReservation(String docId) {
    reservations.removeWhere((r) => r.docId == docId);
    notifyListeners();
  }

  void toggleSelected(String docId) {
    int index = reservations.indexWhere((r) => r.docId == docId);
    if (index != -1) {
      reservations[index].isSelected = !reservations[index].isSelected;
      notifyListeners();
    }
  }
}