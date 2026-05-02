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

Built with:
- 🧱 Feature-first Clean Architecture  
- 🔁 Riverpod state management  
- ⚡ Scalable and maintainable structure  

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
- Route drawing using polylines
- Distance & time estimation

### 🎨 UI/UX
- Clean modern interface
- Dark & Light mode support
- Smooth user experience

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

**Feature-First Clean Architecture + Riverpod**

### 📦 Project Structure

lib/
├── core/  
├── features/  
│   ├── auth/  
│   │   ├── data/  
│   │   ├── domain/  
│   │   └── presentation/  
│  
│   ├── driver/  
│   │   ├── data/  
│   │   ├── domain/  
│   │   └── presentation/  
│  
│   ├── home/  
│   ├── maps/  
│   ├── pending_rides/  
│   ├── polylines_routes/  
│   ├── ride/  
│   ├── shared/  
│  
└── main.dart  

---

### 🧱 Architecture Layers

- **Presentation Layer** → UI & state handling  
- **Domain Layer** → Business logic & use cases  
- **Data Layer** → Firebase & API integration  

---

## 🔁 State Management (Riverpod)

- Reactive and scalable state management
- Clean separation of business logic from UI
- Dependency injection support

Used for:
- Authentication state  
- Ride lifecycle updates  
- User & driver data  

---

## 🔄 Ride Lifecycle

- 🟡 Pending → Created by user  
- 🔵 Accepted → Accepted by driver  
- 🟢 Completed → Ride finished  

---

## 🛠️ Tech Stack

| Tech              | Usage                |
|------------------|---------------------|
| Flutter          | UI Development       |
| Firebase Auth    | Authentication       |
| Firestore        | Database             |
| Riverpod         | State Management     |
| OpenStreetMap    | Maps                 |
| OpenRouteService | Routing              |
| Photon API       | Place Search         |

---

## ⚙️ Getting Started

### 1. Clone the repository
git clone https://github.com/your-username/bookmyride.git  
cd bookmyride  

### 2. Install dependencies
flutter pub get  

### 3. Run the app
flutter run  

---

## 🔐 Configuration

- Add Firebase configuration files:
  - google-services.json  
  - GoogleService-Info.plist  
- Enable Phone Authentication  
- Configure routing & search APIs  

---

## 🚀 Future Improvements

- 📍 Real-time driver tracking  
- 💬 In-app chat  
- 💳 Payment integration  
- 🔔 Push notifications  
- ❌ Ride cancellation  
- 🧑‍💼 Admin dashboard  

---

## 👨‍💻 Author

**Ebin Antony**

---

## ⭐ Support

If you like this project, give it a ⭐ on GitHub!

---

<div align="center">

✨ Built with Flutter & Passion ✨

</div>