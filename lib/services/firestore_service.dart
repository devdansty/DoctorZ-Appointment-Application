import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import '../model/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save user during registration
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  // Get current user's profile
  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // Get all users (admin use)
  Future<List<UserModel>> getAllUsers() async {
    final query = await _db.collection('users').get();
    return query.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Delete a user (admin)
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Book an appointment
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _db.collection('appointments').add(appointment.toMap());
  }

  // Get appointments for a patient
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    final query = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    return query.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get appointments for a doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    final query = await _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    return query.docs
        .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String id, String status) async {
    await _db.collection('appointments').doc(id).update({'status': status});
  }

  // Add availability slot for doctor
  Future<void> addAvailabilitySlot(String doctorId, String time) async {
    await _db
        .collection('users')
        .doc(doctorId)
        .collection('availability')
        .add({'time': time});
  }

  // Get availability slots for a doctor
  Future<List<String>> getAvailabilitySlots(String doctorId) async {
    final query = await _db
        .collection('users')
        .doc(doctorId)
        .collection('availability')
        .get();

    return query.docs.map((doc) => doc.data()['time'] as String).toList();
  }

  // Delete an appointment (admin)
  Future<void> deleteAppointment(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).delete();
  }

  // Count users by role
  Future<Map<String, int>> countUsersByRole() async {
    final query = await _db.collection('users').get();
    int doctors = 0;
    int patients = 0;

    for (var doc in query.docs) {
      final role = doc.data()['role'];
      if (role == 'doctor') doctors++;
      if (role == 'patient') patients++;
    }

    return {
      'doctors': doctors,
      'patients': patients,
    };
  }
}
