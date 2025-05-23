class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String doctorName;
  final DateTime dateTime;
  final String status; // e.g., scheduled, completed, cancelled

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.dateTime,
    required this.status,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      dateTime: DateTime.parse(data['dateTime']),
      status: data['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
    };
  }
}
