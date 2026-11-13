# Omni Delivery & POS Mobile Client — Developer Architecture Guide

This mobile application is built with **Flutter (Dart 3.x)** using **Clean Feature-First Architecture** designed for high security, production stability, maintainability, and complete API integration with the FastAPI backend and Neon Cloud PostgreSQL.

---

## 📁 Directory Structure & Standard Patterns

```
lib/
├── core/                         # Enterprise Infrastructure & Shared Utilities
│   ├── constants/
│   │   ├── api_constants.dart    # Dynamic Base URL (10.0.2.2 vs 127.0.0.1) & Endpoints
│   │   └── app_colors.dart       # Modern UI Palette (Blue, Emerald, Slate)
│   ├── network/
│   │   └── api_client.dart       # Central HTTP Client with Auto Bearer JWT & Timeout
│   ├── storage/
│   │   └── storage_service.dart  # SharedPreferences for Tokens, Addresses, Settings
│   └── theme/
│       └── app_theme.dart        # Unified Material 3 Design Theme
│
├── models/                       # Strongly-typed Data Transfer Objects (DTO)
│   ├── user_model.dart           # User profile, roles (customer, cashier, driver, admin)
│   ├── product_model.dart        # Product catalog, discounts, stock, rating
│   ├── category_model.dart       # Food & store categories
│   ├── branch_model.dart         # Store branches with addresses & phone
│   └── order_model.dart          # Orders, line items & real-time delivery tracking
│
├── services/                     # Repository & Network API Service Layer
│   ├── auth_service.dart         # Login, Register, Google Auth, Profile
│   ├── product_service.dart      # Catalog fetching, search & category filtering
│   └── order_service.dart        # Checkout, order placement, tracking timeline
│
├── state/                        # Reactive State Management (Zero Boilerplate)
│   ├── auth_controller.dart      # User session, auto-login bootstrap, auth events
│   └── cart_controller.dart      # Global cart, quantity stepper, coupons, totals
│
├── widgets/                      # Reusable UI Components
│   ├── custom_button.dart        # Primary/Outlined button with loading state
│   ├── custom_text_field.dart    # Styled inputs with validation & password toggle
│   ├── product_card.dart         # E-commerce card with image cache & quick "+" add
│   ├── status_badge.dart         # Localized Khmer badges for order status
│   └── empty_state.dart          # Clean illustrations for empty lists
│
├── screens/                      # User Interface Views
│   ├── splash/                   # App bootloader & token verification
│   ├── auth/                     # Tabbed Login (Sign In / Register / Google Auth)
│   ├── home/                     # Catalog, Branch Selector, Promo Banner, Grid
│   ├── cart/                     # Shopping cart, delivery address, vouchers, checkout
│   ├── orders/                   # Order history & live delivery tracking timeline
│   └── profile/                  # Account info, branch switch, server URL config
│
└── main.dart                     # Application Entry Point & Global Config
```

---

## 🔒 Security & Networking Best Practices

1. **Bearer Token Auto-Injection:**
   - When a user logs in, the JWT token is stored securely via `StorageService`.
   - `ApiClient` automatically intercepts all authenticated requests and injects:
     ```http
     Authorization: Bearer <TOKEN>
     ```
   - If a `401 Unauthorized` response is returned, the stored token is automatically invalidated to prevent stale session bugs.

2. **Cross-Platform API Host Auto-Detection:**
   - **Android Emulator:** Automatically defaults to `http://10.0.2.2:8000/api/v1` to communicate with the host machine.
   - **Windows / Web / iOS Simulator:** Automatically defaults to `http://127.0.0.1:8000/api/v1`.
   - **Custom LAN / Production IP:** Developers and testers can tap the **Server Settings** icon on the Login screen or Profile screen to set any custom IP (e.g., `http://192.168.1.150:8000/api/v1`) without modifying code.

3. **Unicode & Khmer Text Fidelity:**
   - All network responses are decoded using `utf8.decode(response.bodyBytes)` to guarantee Khmer fonts and characters render without corruption.

4. **Defensive Model Parsing:**
   - All models use null-safe type casting with safe fallbacks (`json['price'] as num? ?? 0.0`) so missing or malformed fields never crash the UI.

---

## 🚀 How Future Developers Can Extend the App

### Adding a New Screen
1. Create your screen inside `lib/screens/<feature>/<feature>_screen.dart`.
2. Connect to existing controllers (`AuthController.instance` or `CartController.instance`) using `ListenableBuilder`.
3. Use pre-built widgets (`CustomButton`, `CustomTextField`, `EmptyState`) to maintain design consistency.

### Adding a New API Endpoint
1. Define the route constant in `lib/core/constants/api_constants.dart`.
2. Add the corresponding method in `lib/services/<domain>_service.dart` calling `_api.get()`, `_api.post()`, or `_api.put()`.
3. Create or update the model in `lib/models/`.
