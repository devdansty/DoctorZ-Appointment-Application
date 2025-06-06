# 🩺 DoctorZApp – Doctor Appointment Booking App

DoctorZApp is a Flutter-based cross-platform mobile application designed to streamline the process of booking appointments between doctors and patients. The app features role-based access control for **Admin**, **Doctor**, and **Patient** with Firebase as the backend.

---

## 🚀 Features

### 👤 Authentication & Roles
- Firebase Authentication for secure login & registration
- Role-based dashboard routing:
  - **Admin Dashboard**
  - **Doctor Dashboard**
  - **Patient Dashboard**

### 🧑‍⚕️ Doctor Features
- Set availability for appointments
- View booked appointments
- Manage schedule

### 🧑‍💼 Patient Features
- View available doctors
- Book appointments
- View appointment history

### 🛠️ Admin Features
- Manage users (patients and doctors)
- Monitor system activity (future scope)

---

## 🧱 Tech Stack

| Layer            | Technology                      |
|------------------|----------------------------------|
| **Frontend**     | Flutter                          |
| **Backend**      | Firebase (Auth, Firestore, Core) |
| **Routing**      | Flutter Navigator                |
| **State**        | Stateful Widgets                 |

---

## 📁 Project Structure
lib/
├── pages/
│ ├── login_screen.dart
│ ├── register_screen.dart
│ ├── admin_dashboard.dart
│ ├── doctor_dashboard.dart
│ ├── patient_dashboard.dart
│ ├── book_appointment.dart
│ ├── appointment_history.dart
│ ├── doctor_appointments.dart
│ └── add_availability.dart
├── services/
│ └── firestore_service.dart
└── main.dart


## 🧑‍💻 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/devdansty/doctorzapp.git
cd doctorzapp
