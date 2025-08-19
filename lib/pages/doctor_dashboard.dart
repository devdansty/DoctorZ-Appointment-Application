import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? doctorData;
  bool loading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchDoctorData();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  Future<void> fetchDoctorData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Not logged in, redirect to login
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (!docSnapshot.exists || docSnapshot.data()?['role'] != 'doctor') {
        // Not a doctor, redirect elsewhere
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      setState(() {
        doctorData = docSnapshot.data();
        loading = false;
      });
    } catch (e) {
      print('Error fetching doctor data: $e');
      // Handle error e.g. show dialog
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Dr. ${doctorData?['name'] ?? ''}',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Email: ${doctorData?['email'] ?? ''}'),
              SizedBox(height: 10),
              Text('Specialty: ${doctorData?['specialty'] ?? 'N/A'}'),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.schedule),
                label: Text('View Appointments'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/doctorAppointments');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add_box),
                label: Text('Add Availability'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/addAvailability');
                },
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
