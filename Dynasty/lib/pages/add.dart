import 'package:app/pages/reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPage extends StatefulWidget {

  //final Function onReservationAdded;
  //final DateTime selectedDate;

  //AddPage({Key? key, required this.selectedDate}) : super(key: key);

  final Reservation? existingReservation;

  final DateTime selectedDate;

  AddPage({Key? key, this.existingReservation, required this.selectedDate}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay _time = TimeOfDay.now();
  DateTime time_stamp = DateTime.now();

  DateTime selectedDate = DateTime.now(); // This stores the selected date for the reservation



  int? tableNumber;
  String? notes;
  String? name_class;
  int? people_class;
  String? phNumber_class;
  String? time_class;
  //String? time_stamp;

  // Function to combine date and time
  DateTime getFullReservationDateTime() {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _time.hour,
      _time.minute,
    );
  }

  TextEditingController peopleController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController timeStampController = TextEditingController();

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  // use 'jm' for 12-hour format
    return format.format(dt);
  }


  @override
  void dispose() {
    // Dispose the controllers when the state is disposed
    peopleController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    notesController.dispose();
    timeStampController.dispose();
    // Don't forget to call the super method
    super.dispose();
  }

  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    if (widget.existingReservation != null) {
      peopleController.text = widget.existingReservation!.people?.toString() ?? '';
      nameController.text = widget.existingReservation!.name ?? '';
      phoneNumberController.text = widget.existingReservation!.phoneNumber ?? '';
      notesController.text = widget.existingReservation!.notes ?? '';
      tableNumber = widget.existingReservation!.tableNumber;
      _time = TimeOfDay.fromDateTime(widget.existingReservation!.reservationTime);
      timeStampController.text = widget.existingReservation!.timeStamp ?? '';
    }
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int crossAxisCount = screenWidth > screenHeight ? 10 : 5;
    double itemWidth = screenWidth / crossAxisCount;
    double itemHeight = itemWidth; // Assuming crossAxisCount is 5
    double gridViewHeight = itemHeight * crossAxisCount; // If you want 5 rows to be displayed

    double commonFontSize = 16.0;

    //DateTime selectedDate = widget.selectedDate;

    String appBarTitle = widget.existingReservation == null ? 'Add Reservation' : 'Edit Reservation';

    return Scaffold(
      appBar: AppBar(
      title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 16.0),
              TextFormField(
                controller: peopleController,
                decoration: InputDecoration(labelText: 'Number of People'),
                style: TextStyle(fontSize: commonFontSize),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter number of people';
                  return null;
                },
                onSaved: (value) {
                  people_class = int.tryParse(peopleController.text);
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Select Table Number',
                style: TextStyle(fontSize: commonFontSize), // Use the same font size here
              ),
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: itemWidth / itemWidth, // 1:1 ratio
                physics: ScrollPhysics(),
                shrinkWrap: true,
                children: List.generate(22, (index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        tableNumber = index + 1;
                      });
                    },
                    child: Card(
                      color: tableNumber == index + 1 ? Colors.blue : Colors.white,
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 26,
                            color: tableNumber == index + 1 ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a name';
                  return null;
                },
                onSaved: (value) {
                  name_class = nameController.text;

                },
              ),

              SizedBox(height: 16.0),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a phone number';
                  return null;
                },
                onSaved: (value) {
                  phNumber_class = phoneNumberController.text;
                },
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
                    hintText: _time != null ? 'Select Time Slot' : null,
                  ),
                  child: Text(_time != null ? _time.format(context) : ''),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) {
                  notes = notesController.text;
                },
              ),
              SizedBox(height: 16.0),

              if (widget.existingReservation != null)
                ElevatedButton(
                  child: Text('Save Reservation'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    DateTime reservationDateTime = getFullReservationDateTime();
                    String formattedTime = formatTimeOfDay(_time);
                    //String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(reservationDateTime);
                    String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(time_stamp);
                    Map<String, dynamic> reservationData = {
                      'attended_class': widget.existingReservation?.attended ?? 0,
                      'name_class': name_class,
                      'notes_class': notes?.isEmpty ?? true ? 'none' : notes,
                      'people_class': people_class,
                      'phNumber_class': phNumber_class,
                      'table_class': tableNumber,
                      //'timeStamp_class': formattedDate,
                      'timeStamp_class': formattedDate,
                      'time_class': _time.format(context),
                      //'time_class': formattedTime,
                    };

                    if (widget.existingReservation != null) {
                      // Update existing reservation
                      await FirebaseFirestore.instance
                          .collection('reservations')
                          .doc(widget.existingReservation!.docId)
                          .update(reservationData);
                    } else {
                      // Add new reservation
                      await FirebaseFirestore.instance
                          .collection('reservations')
                          .add(reservationData);
                    }

                    Navigator.pop(context);
                  }
                },
              ),


              if (widget.existingReservation == null)
                ElevatedButton(
                  child: Text('Add Reservation'),
                onPressed: () async {
                  if (tableNumber == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Alert'),
                          content: const Text('Please select a table number.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    DateTime reservationDateTime = getFullReservationDateTime();
                    String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(reservationDateTime);
                    String formattedTime = formatTimeOfDay(_time);


                    await FirebaseFirestore.instance.collection('reservations').add({
                      'attended_class': 0,
                      'name_class': name_class,
                      'notes_class': notes?.isEmpty ?? true ? 'none' : notes,
                      'people_class': people_class,
                      'phNumber_class': phNumber_class,
                      'table_class': tableNumber,
                      //'timeStamp_class': selectedDate,
                      'timeStamp_class': formattedDate,
                      'time_class': _time.format(context),
                      //'time_class': formattedTime,
                    });
                    Navigator.pop(context);
                    //widget.onReservationAdded(); // Call the callback
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Alert'),
                          content: const Text('Please enter all required fields.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {

        _time = newTime;
        //time_stamp = DateTime.now();
      });
    }
  }
}
