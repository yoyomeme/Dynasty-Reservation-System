import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Event {
  final String title;
  const Event(this.title);
  @override
  String toString() => title;
}

// Declare kEvents as a variable that can be updated later
LinkedHashMap<DateTime, List<Event>> kEvents =
    LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

// Initial _kEventSource definition remains the same
final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
};

/*final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);*/
/*
final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}'))
}..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });*/
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
//final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
//final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
final kFirstDay = DateTime(2024, 1, 1); // 1st January 2024
final kLastDay = DateTime(2027, 12, 31); // 31st December 2024

// Function to fetch holidays and update kEvents
Future<void> fetchAndSetHolidays() async {
  const String apiKey = 'bl77xGdg5Honsc9j4F95sPd8NF11saIQ';
  const String country = 'AU'; // Specify your country code
  int year = 2029;
  year = DateTime.now().year;

  var url = Uri.parse(
      'https://calendarific.com/api/v2/holidays?&api_key=$apiKey&country=$country&year=$year');

  try {
    var response = await http.get(url);
    var data = json.decode(response.body);

    if (response.statusCode == 200 && data['response']['holidays'] != null) {
      var fetchedHolidays = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );

      for (var holiday in data['response']['holidays']) {
        DateTime holidayDate = DateTime.parse(holiday['date']['iso']);
        fetchedHolidays[holidayDate] = [Event(holiday['name'])];
      }

      // Replace the existing kEvents with the new holidays map
      kEvents
        ..clear()
        ..addAll(fetchedHolidays);
      //..addAll(_kEventSource); // Keeping the original events as well
    }
  } catch (e) {
    print('Error fetching holidays: $year');
  }
}
