# Goalr – Step Tracking & Daily Progress App

![SwiftUI](https://img.shields.io/badge/SwiftUI-Enabled-blue?logo=swift)
![iOS](https://img.shields.io/badge/iOS-15%2B-lightgrey?logo=apple)
![License](https://img.shields.io/badge/License-MIT-green)

Goalr is a modern, elegantly designed step-tracking iOS app built with **SwiftUI** and **HealthKit**. It keeps users motivated by providing **real-time step tracking**, **animated progress visuals**, and **goal celebration effects**, turning fitness into a rewarding experience.

---

## ✨ Features

* **Daily & Weekly Step Tracking**
  Animated progress circles and weekly summaries keep users aware of their activity.

* **Personal Step Goals**
  Track your remaining steps and celebrate goal achievements.

* **HealthKit Integration**
  Securely fetch and display real-time step counts.

* **Motivational Visuals**
  Particle bursts, glowing progress rings, and pulse effects for milestones.

* **Smooth Onboarding**
  Includes a splash screen and user registration for a seamless start.

---

## 🛠 Technical Highlights

* **SwiftUI-first Architecture** – Declarative, reusable components.
* **MVVM Pattern** – Clear separation of models, views, and logic.
* **HealthKit & Core Motion Integration** – Privacy-focused and efficient.
* **Custom Animations** – Smooth transitions and particle effects.
* **Modular Project Structure** – Scalable and maintainable.

```
GoalrApp/
├── Models/
│   ├── User.swift
│   ├── DailyProgress.swift
├── ViewModels/
│   ├── GoalrViewModel.swift
├── Managers/
│   ├── HealthKitManager.swift
│   ├── StepCounterManager.swift
├── Views/
│   ├── Components/
│   │   ├── ProgressCircleView.swift
│   │   ├── ParticleBurstView.swift
│   │   ├── WeeklyProgressView.swift
│   ├── Screens/
│       ├── HomeView.swift
│       ├── GoalPickerView.swift
│       ├── RegistrationView.swift
│       ├── SplashScreenView.swift
└── GoalrAppApp.swift
```

---

## 🚀 Getting Started

### Prerequisites

* macOS with **Xcode 15+**
* iOS 15+ device or simulator
* HealthKit permissions enabled

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/abgolor/goalr-ios.git
   ```
2. Open the project:

   ```bash
   cd Goalr
   open Goalr.xcodeproj
   ```
3. Run the app (`Cmd + R`) on your preferred device.
4. Grant **HealthKit** access when prompted.

---

## 📸 Screenshots

*(Screenshot coming soon!)*

---

## 🔮 Roadmap

* Daily reminders and notifications
* Real-time iOS widgets
* Social sharing of achievements

---

## 📄 License

Licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

**Goalr** is built to inspire **motivation, simplicity, and delightful design** for your daily activity journey.
