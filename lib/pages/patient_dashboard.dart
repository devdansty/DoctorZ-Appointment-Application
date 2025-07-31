import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientDashboard extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              user?.email ?? 'No Email',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),

            _dashboardButton(
              context,
              title: "📅 Book Appointment",
              route: "/bookAppointment",
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 20),

            _dashboardButton(
              context,
              title: "📖 Appointment History",
              route: "/appointmentHistory",
              color: Colors.grey[800]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(BuildContext context,
      {required String title, required String route, required Color color}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
