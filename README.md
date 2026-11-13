# 📱 Omni E-Commerce & POS Mobile / Web Client

A modern, high-performance, and feature-rich E-Commerce & Delivery application built with **Flutter (Dart 3.x)**. Supports **Android**, **iOS**, and **Web**, featuring real-time delivery tracking, multi-branch ordering, shopping cart with voucher coupons, and seamless REST API integration.

---

## 🌟 Key Features

- **🛍️ Complete E-Commerce Catalog:** Browse items by category, live instant search, rating badges, discount percentages, and stock indicators.
- **🏬 Multi-Branch Ready:** Switch store branches in real-time.
- **🛒 Smart Shopping Cart:** Interactive +/- quantity steppers, promo code discount calculation (e.g. `OMNI20`, `FREESHIP`), and delivery notes.
- **🚴 Live Delivery Tracking:** Interactive multi-step timeline (Order Placed → Preparing Food → Out for Delivery → Delivered) with driver details and real-time polling.
- **🔐 Secure Authentication:** Tabbed Sign In & Register screens with JWT token persistence via `SharedPreferences`.
- **🌐 100% Responsive Web Support:** Fully optimized for desktop browsers and mobile web.

---

## 📁 Clean Code Architecture

```
mobile_app/
├── lib/
│   ├── core/
│   │   ├── constants/        # API routes, dynamic base URLs, brand colors
│   │   ├── network/          # ApiClient with auto Bearer token injection
│   │   ├── storage/          # SharedPreferences persistence layer
│   │   └── theme/            # Material 3 styling & typography
│   ├── models/               # Strongly-typed data models (User, Product, Order, etc.)
│   ├── services/             # API services for Auth, Products, and Orders
│   ├── state/                # Reactive state controllers (AuthController, CartController)
│   ├── widgets/              # Reusable components (Buttons, Inputs, Cards, Badges)
│   ├── screens/              # App screens (Splash, Auth, Home, Cart, Orders, Profile)
│   └── main.dart             # Application root entry point
├── web/                      # Web platform assets and HTML template
├── vercel.json               # Vercel deployment configuration
├── vercel-build.sh           # Automated Vercel build script
└── pubspec.yaml              # Flutter dependencies and assets
```

---

## 🛠️ Local Development

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Android Device / Emulator
```bash
flutter run
```

### 3. Run on Web (Chrome)
```bash
flutter run -d chrome
```

---

## 🚀 Deploying to Vercel (Vercel.com)

This project is pre-configured for **1-Click Web Deployment** on Vercel using `vercel.json` and `vercel-build.sh`.

### Method A: Connect GitHub Repository (Automatic CI/CD)
1. Push this repository to GitHub: `https://github.com/samet168/E-commerce-App.git`.
2. Go to your [Vercel Dashboard](https://vercel.com/dashboard).
3. Click **Add New...** → **Project**.
4. Import the `samet168/E-commerce-App` repository.
5. Vercel will automatically detect `vercel.json` and run `vercel-build.sh`.
6. Click **Deploy**. Vercel will build and publish your Flutter Web app with a live URL (e.g., `https://e-commerce-app-xxx.vercel.app`)!

### Method B: Deploy Using Vercel CLI (Instant)
If you already built the web release locally (`flutter build web --release`):
```bash
# Install Vercel CLI globally if not already installed
npm install -g vercel

# Deploy build/web directory directly
cd build/web
vercel --prod
```

---

## 📄 License
MIT License. Developed for Omni POS & Delivery Ecosystem.
