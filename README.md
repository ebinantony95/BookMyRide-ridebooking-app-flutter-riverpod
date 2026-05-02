# 🚖 BookMyRide – Full Stack Ride Booking App

BookMyRide is a **Flutter + Firebase powered ride-booking application** that connects users and drivers in real-time.  
The app supports **OTP-based authentication**, **role-based access (User/Driver)**, and a complete **ride lifecycle system** with map-based navigation.

It is built using a **Feature-first Clean Architecture** and uses **Riverpod for state management**, ensuring scalability, maintainability, and clean separation of concerns.

---

## ✨ Key Highlights

- 🔐 OTP-based authentication (Phone login)
- 👥 Role-based system (User / Driver)
- 🗺️ OpenStreetMap integration for maps & routing
- 🚕 Real-time ride lifecycle:
  - Pending → Accepted → Completed
- 📊 Driver earnings & ride history tracking
- 🌙 Light & Dark theme support
- 🧱 Feature-first Clean Architecture
- 🔁 Riverpod state management

---

## 📱 App Screens

### 🔐 Authentication
<p align="center">
  <img src="assets/screens/loginLIght.png" width="230"/>
  <img src="assets/screens/loginDark.png" width="230"/>
  <img src="assets/screens/otpDark.png" width="230"/>
</p>

---

### 👤 Onboarding & Role Selection
<p align="center">
  <img src="assets/screens/profileComplete.png" width="230"/>
  <img src="assets/screens/roleselection.png" width="230"/>
  <img src="assets/screens/driverProfileComplete.png" width="230"/>
</p>

---

### 🧑 User Flow
<p align="center">
  <img src="assets/screens/uesrhome.png" width="230"/>
  <img src="assets/screens/makeRide.png" width="230"/>
  <img src="assets/screens/ride.png" width="230"/>
  <img src="assets/screens/rideHostory.png" width="230"/>
</p>

---

### 🚗 Driver Flow
<p align="center">
  <img src="assets/screens/driverhome.png" width="230"/>
  <img src="assets/screens/rideAccept.png" width="230"/>
  <img src="assets/screens/driverHistory.png" width="230"/>
</p>

---

### ⚙️ Drawer & Settings
<p align="center">
  <img src="assets/screens/drawar.png" width="230"/>
</p>

---

## 🏗️ Architecture

This project follows a **feature-first clean architecture**, where each feature is modular and self-contained.

### 📦 Project Structure

```bash
lib/
├── core/                         # Shared utilities, services, constants
├── features/
│   ├── auth/                     # Authentication (OTP login)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── driver/                   # Driver-side features
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── home/                     # Home & navigation
│   ├── maps/                     # Map rendering & location handling
│   ├── pending_rides/            # Ride request handling
│   ├── polylines_routes/         # Route drawing logic
│   ├── ride/                     # Ride lifecycle management
│   ├── shared/                   # Shared feature-level components
│
├── main.dart


### 🧱 Layers

- **Presentation Layer** → UI & Widgets  
- **Domain Layer** → Business logic & entities  
- **Data Layer** → Firebase integration & APIs  

---

## 🔁 State Management (Riverpod)

- Uses **Riverpod** for scalable and reactive state management
- Ensures clear separation between UI and business logic
- Provides dependency injection and testability

Handles:
- Authentication state
- Ride lifecycle updates
- User & driver data

---

## 🔄 Ride Lifecycle

- 🟡 **Pending** – Created by user  
- 🔵 **Accepted** – Accepted by driver  
- 🟢 **Completed** – Ride finished  

---

## 🛠️ Tech Stack

- **Frontend:** Flutter  
- **Backend:** Firebase (Authentication + Firestore)  
- **State Management:** Redux  
- **Architecture:** Feature-first Clean Architecture  

### 🌍 Maps & Location
- OpenStreetMap  
- OpenRouteService  
- Photon API (Place Search)  
- Geolocator  

---

## ⚙️ Installation

```bash
git clone https://github.com/your-username/bookmyride.git
cd bookmyride
flutter pub get
flutter run