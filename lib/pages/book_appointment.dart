import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _bookSlot(
      BuildContext context, DocumentSnapshot slotDoc) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final slotData = slotDoc.data() as Map<String, dynamic>;
    final doctorId = slotData['doctorId'];
    final slotTime = slotData['dateTime'];

    // Get patient name (optional - you may store name during registration)
    final patientSnapshot =
    await _firestore.collection('users').doc(user.uid).get();
    final patientName = patientSnapshot['name'] ?? 'Patient';

    try {
      // Add to appointments collection
      await _firestore.collection('appointments').add({
        'doctorId': doctorId,
        'patientId': user.uid,
        'patientName': patientName,
        'dateTime': slotTime,
        'status': 'Confirmed',
      });

      // Mark slot as booked
      await _firestore
          .collection('availability')
          .doc(slotDoc.id)
          .update({'status': 'booked'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );
    } catch (e) {
      print('Booking failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('availability')
            .where('status', isEqualTo: 'available')
            .orderBy('dateTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error loading slots.'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No available slots.'));

          final slots = snapshot.data!.docs;

          return ListView.builder(
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final data = slots[index].data() as Map<String, dynamic>;
              final slotTime = (data['dateTime'] as Timestamp).toDate();
              final doctorId = data['doctorId'];

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
                      title: Text(doctorName),
                      subtitle:
                      Text(DateFormat.yMMMEd().add_jm().format(slotTime)),
                      trailing: ElevatedButton(
                        child: Text('Book'),
                        onPressed: () => _bookSlot(context, slots[index]),
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
