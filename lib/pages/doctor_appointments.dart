import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String? doctorId = _auth.currentUser?.uid;

    if (doctorId == null) {
      return Scaffold(
        body: Center(child: Text("Unauthorized access.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Appointments'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .orderBy('dateTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching appointments.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments scheduled.'));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;

              final patientName = data['patientName'] ?? 'N/A';
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final status = data['status'] ?? 'Confirmed';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
                  title: Text(patientName),
                  subtitle: Text('${dateTime.toLocal()}'),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Cancelled' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
