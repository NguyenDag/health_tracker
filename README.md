# 🏥 HealthTracker

**HealthTracker** is a premium mobile application designed to help users effortlessly monitor their vitals, track health progress, and receive AI-powered insights. Built with **Flutter** and **Supabase**, it offers a seamless experience for both regular users and health administrators.

---

## ✨ Key Features

### 👤 For Users
*   **Smart Dashboard**: A bird's eye view of your current health status and recent logs.
*   **Vitals Tracking**: Easily record and monitor metrics like Weight, Height, and customized health thresholds.
*   **Activity Statistics**: Visualize your health data over time with beautiful charts and logs.
*   **Personalized Profile**: Manage your biometric data and secure your account with ease.
*   **Health Notifications**: Stay alerted when your measurements cross important thresholds.

### 🛡️ For Administrators
*   **Admin Dashboard**: Comprehensive analytics and user growth monitoring.
*   **User Management**: Efficiently oversee user profiles and active sessions.
*   **AI Config & Thresholds**: Fine-tune the health logic and global notification thresholds.
*   **System Controls**: Advanced management of application-wide configurations.

---

## 🎨 Premium Experience
*   **Stunning UI/UX**: Modern design with vibrant gradients, glassmorphism, and smooth micro-animations.
*   **Centered Brand Identity**: A professional splash screen that puts the focus on simplicity.
*   **Native & Localized**: Fully localized in **Vietnamese** with user-friendly error messages and inline feedback.
*   **Secure Auth Flow**: Robust authentication including Forgot Password and strict input validation.

---

## 🛠️ Technical Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) |
| **Language** | Dart |
| **Backend / Auth** | [Supabase](https://supabase.com/) |
| **State Management**| Provider |
| **Local Database** | sqflite |
| **Environment** | flutter_dotenv |

---

## 🏛️ Architecture

The project follows a modular **MVVM (Model-View-ViewModel)** architectural pattern combined with **Repository Pattern** to ensure scalability and testability:

*   📂 **core**: Constants, Themes, Router, and DI setup.
*   📂 **data**: Repository implementations and data sources.
*   📂 **domain**: Entities and repository interfaces.
*   📂 **viewmodels**: Business logic and state management.
*   📂 **views**: Organized UI components (Admin, User, Shared Widgets).

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Dart SDK
- Supabase Account

### Installation

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/NguyenDag/health_tracker.git
    cd health_tracker
    ```

2.  **Environment Variables**
    Create a `.env` file in the root directory and add your Supabase credentials:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```

3.  **Fetch Dependencies**
    ```bash
    flutter pub get
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 👥 Contributors
- **Nguyen Dag** - Lead Developer

---

*Built with ❤️ for a healthier tomorrow.*
