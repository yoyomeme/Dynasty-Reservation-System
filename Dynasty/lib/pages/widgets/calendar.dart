import 'dart:ui';
import 'package:app/pages/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TableEventsExample extends StatefulWidget {
  final Function(DateTime) onDaySelected;
  final DateTime initialSelectedDate;
  const TableEventsExample({
    Key? key,
    required this.onDaySelected,
    required this.initialSelectedDate,
  }) : super(key: key);

  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;

  Map<DateTime, List<Event>> _holidays = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDate; // Use the passed selected date
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchHolidays();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _fetchHolidays() async {
    const String apiKey = 'bl77xGdg5Honsc9j4F95sPd8NF11saIQ';
    const String country = 'AU'; // Specify your country code
    int year = DateTime.now().year;

    var url = Uri.parse(
        'https://calendarific.com/api/v2/holidays?&api_key=$apiKey&country=$country&year=$year');

    try {
      var response = await http.get(url);
      var data = json.decode(response.body);

      if (response.statusCode == 200 && data['response']['holidays'] != null) {
        setState(() {
          for (var holiday in data['response']['holidays']) {
            DateTime holidayDate = DateTime.parse(holiday['date']['iso']);
            _holidays[holidayDate] = [
              Event(holiday['name'])
            ]; // Adapt to your Event class
          }
        });
        print("Fetched holidays: $_holidays");
      }
    } catch (e) {
      print('Error fetching holidays: $e');
    }
    print("Holidays fetched and set state called");
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Combine events from kEvents and _holidays
    var events = kEvents[day] ?? [];
    var holidayEvents = _holidays[day] ?? [];
    //print("Getting events for day $day: ${_holidays[day]}");

    return [...events, ...holidayEvents];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    //if (!isSameDay(_selectedDay, selectedDay)) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null; // Important to clean those
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
    _selectedEvents.value = _getEventsForDay(selectedDay);
    widget.onDaySelected(selectedDay);
    //}
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Event> monthHolidays = _getMonthHolidays();

    return SingleChildScrollView(
      // Add SingleChildScrollView
      child: ConstrainedBox(
        // Constrain the height
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.6, // 60% of screen height
        ),
        child: Column(
          children: [
            Container(
              //margin: EdgeInsets.all(8.0), // Add margin if needed
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 1),
                borderRadius:
                    BorderRadius.circular(12.0), // Set the border radius here
                color: Colors.transparent,
              ),
              child: TableCalendar<Event>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 101, 167, 221),
                    shape: BoxShape.circle,
                  ),
                  // Style for the selected date
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 177, 200),
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,

                  defaultDecoration: BoxDecoration(
                    color:
                        Colors.transparent, // Set the default background color
                    //borderRadius: BorderRadius.circular(6.0),
                  ),
                  weekendDecoration: BoxDecoration(
                    color:
                        Colors.transparent, // Set the weekend background color
                  ),
                ),
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  setState(() {
                    // This will trigger the ListView.builder to rebuild with new holidays
                  });
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: monthHolidays.length,
                itemBuilder: (context, index) {
                  Event holiday = monthHolidays[index];
                  DateTime holidayDate = _holidays.keys.firstWhere(
                    (k) => _holidays[k]!.contains(holiday),
                    orElse: () => DateTime.now(),
                  );
                  String formattedDate = DateFormat('yyyy-MM-dd')
                      .format(holidayDate); // Format date as needed

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text('${holiday.title} ($formattedDate)'),
                      onTap: () {
                        setState(() {
                          _selectedDay = _holidays.keys.firstWhere(
                            (k) => _holidays[k]!.contains(holiday),
                            orElse: () => DateTime.now(),
                          );
                          _focusedDay = _selectedDay!;
                        });
                        widget.onDaySelected(_selectedDay!);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Event> _getMonthHolidays() {
    // Filter holidays for the current month
    return _holidays.entries
        .where((entry) =>
            entry.key.month == _focusedDay.month &&
            entry.key.year == _focusedDay.year)
        .expand((entry) => entry.value)
        .toList();
  }
}
