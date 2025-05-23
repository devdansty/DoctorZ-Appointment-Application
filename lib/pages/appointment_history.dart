import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("You must be logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment History'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Something went wrong.'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No appointments found.'));

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              final doctorId = data['doctorId'];
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final status = data['status'] ?? 'Unknown';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(doctorId).get(),
                builder: (context, doctorSnapshot) {
                  String doctorName = 'Loading...';
                  if (doctorSnapshot.hasData &&
                      doctorSnapshot.data!.exists &&
                      doctorSnapshot.data!.data() != null) {
                    final doctorData =
                    doctorSnapshot.data!.data() as Map<String, dynamic>;
                    doctorName = doctorData['name'] ?? 'Doctor';
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Dr. $doctorName'),
                      subtitle: Text(DateFormat.yMMMEd().add_jm().format(dateTime)),
                      trailing: Chip(
                        label: Text(
                          status,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: status == 'Confirmed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
