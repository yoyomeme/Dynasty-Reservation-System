import 'package:app/firebase_options.dart';
import 'package:app/pages/reservationModal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/home.dart';
import './pages/add.dart';
//import 'pages/widgets/calendar2.dart';
import './pages/edit.dart';
import './pages/reservation.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(
    ChangeNotifierProvider(
      create: (context) => ReservationModel(),
      child: const MyApp(),
    ),
  );
}

//void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation System',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(), // Default home page
        //'/add': (context) => AddPage(selectedDate: null,), // Page to add new reservation
        //'/calendar': (context) => AddPage(selectedDate: null,), //CalendarPage(), // Calendar page
        //'/edit': (context) => AddPage(selectedDate: null,), //EditPage(), // Page to edit reservation
        //'/reservation': (context) => AddPage(selectedDate: null,), //ReservationPage(), // Detailed view of reservation
      },
    );
  }
}
