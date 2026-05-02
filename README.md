<div align="center">

# 🚖 BookMyRide

### 🗺️ Ride • Connect • Travel Smart

<img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=22&duration=3000&pause=1000&color=00C853&center=true&vCenter=true&width=500&lines=Ride+Booking+App;Flutter+%2B+Firebase;Clean+Architecture;Real-time+Ride+Flow" />

---

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Riverpod](https://img.shields.io/badge/State-Riverpod-green)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-purple)

</div>

---

## ✨ About the App

**BookMyRide** is a full-stack ride booking application that connects **users and drivers in real-time**.

It provides a complete ride experience from **booking → acceptance → completion**, powered by maps, location tracking, and real-time updates.

Built with a strong focus on:
- 🧱 Scalable architecture  
- ⚡ Performance  
- 🎯 Real-world usability  

---

## 🚀 Features

### 🔐 Authentication
- Phone number login with OTP
- Secure Firebase authentication

### 👤 User Features
- Live location detection
- Search destination
- Ride fare estimation
- Book rides by vehicle type
- View ride history

### 🚗 Driver Features
- Accept ride requests
- Update ride status
- Track completed rides
- View total earnings

### 🗺️ Maps & Navigation
- OpenStreetMap integration
- Route drawing with polylines
- Distance & time estimation

### 🎨 UI/UX
- Clean modern interface
- Dark & Light mode support
- Smooth animations

---

## 📱 Screenshots

### 🔐 Authentication
<p align="center">
  <img src="assets/screens/loginLIght.png" width="230"/>
  <img src="assets/screens/loginDark.png" width="230"/>
  <img src="assets/screens/otpDark.png" width="230"/>
</p>

---

### 👤 Onboarding
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

## 🧠 Architecture

```bash
Feature-First Clean Architecture + Riverpod
lib/
├── core/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── driver/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── home/
│   ├── maps/
│   ├── pending_rides/
│   ├── polylines_routes/
│   ├── ride/
│   ├── shared/
│
└── main.dart