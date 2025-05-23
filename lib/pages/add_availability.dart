import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAvailabilityScreen extends StatefulWidget {
  @override
  _AddAvailabilityScreenState createState() => _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _submitAvailability() async {
    if (selectedDate == null || selectedTime == null) return;

    setState(() => isLoading = true);

    final DateTime dateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('availability').add({
        'doctorId': user.uid,
        'dateTime': dateTime,
        'status': 'available',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot added successfully!')),
      );

      setState(() {
        selectedDate = null;
        selectedTime = null;
      });
    } catch (e) {
      print("Error: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final String date = selectedDate != null
        ? DateFormat.yMMMd().format(selectedDate!)
        : 'Select date';

    final String time = selectedTime != null
        ? selectedTime!.format(context)
        : 'Select time';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Availability'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Date: $date'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            ListTile(
              title: Text('Time: $time'),
              trailing: Icon(Icons.access_time),
              onTap: () => _pickTime(context),
            ),
            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Add Slot'),
              onPressed: _submitAvailability,
            ),
          ],
        ),
      ),
    );
  }
}
