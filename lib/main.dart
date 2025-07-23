import 'package:doctorzapp/pages/login_screen.dart';
import 'package:doctorzapp/pages/register_screen.dart';
import 'package:doctorzapp/pages/admin_dashboard.dart';
import 'package:doctorzapp/pages/doctor_dashboard.dart';
import 'package:doctorzapp/pages/patient_dashboard.dart';
import 'package:doctorzapp/pages/book_appointment.dart';
import 'package:doctorzapp/pages/appointment_history.dart';
import 'package:doctorzapp/pages/doctor_appointments.dart';
import 'package:doctorzapp/pages/add_availability.dart';
import 'package:doctorzapp/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DoctorZApp());
}

class DoctorZApp extends StatelessWidget {
  const DoctorZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4a6bff),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF4a6bff),
          secondary: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4a6bff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/doctorDashboard': (context) => DoctorDashboard(),
          '/doctorAppointments': (context) => DoctorAppointmentsScreen(),
          '/addAvailability': (context) => AddAvailabilityScreen(),
          '/patientDashboard': (context) => PatientDashboard(),
          '/bookAppointment': (context) => BookAppointmentScreen(),
          '/appointmentHistory': (context) => AppointmentHistoryScreen(),
          '/adminDashboard': (context) => AdminDashboard(),

          // to be created
          // Add other routes as needed
        },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: FirestoreService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (roleSnapshot.hasData) {
                switch (roleSnapshot.data) {
                  case 'admin':
                    return AdminDashboard();
                  case 'doctor':
                    return DoctorDashboard();
                  case 'patient':
                    return PatientDashboard();
                  default:
                    return const LoginScreen();
                }
              } else {
                return const LoginScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
