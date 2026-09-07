# Smart Plant Care System - 70% Prototype Figma UI/UX Design Specification

This specification details the UI layout structure, design tokens, responsive grid system, and component architecture required for designing the **70% Prototype Phase** in **Figma**.

---

## 🎨 1. Design System & Style Tokens

### 1.1 Color Palette
* **Primary Brand Green**: `#2E7D32` (Forest Green - Headers, Primary Buttons, Active Accents)
* **Secondary Emerald**: `#4CAF50` (Vibrant Emerald - Status badges, Progress indicators)
* **Background Dark / Light**: `#0F172A` (Dark Slate Mode) / `#F8FAFC` (Light Crisp Background)
* **Surface Card Fill**: `#1E293B` (Dark Card Surface) / `#FFFFFF` (Light Glass Surface)
* **Accent Warning/Alert**: `#FFB300` (Warm Amber - Low Soil Moisture warning)
* **Text Primary**: `#F8FAFC` (Dark Mode) / `#0F172A` (Light Mode)
* **Text Secondary**: `#94A3B8` (Muted Subtitles)

### 1.2 Typography (Google Fonts - Inter / Outfit)
* **Heading 1 (Screen Titles)**: SemiBold 24px, Line Height 32px
* **Heading 2 (Card Titles)**: SemiBold 18px, Line Height 24px
* **Metric Display (Sensor Numbers)**: Bold 32px, Line Height 38px
* **Body Text**: Regular 14px, Line Height 20px
* **Caption / Timestamp**: Medium 12px, Line Height 16px

### 1.3 Card & Component Elevation
* **Corner Radius**: `16px` for Metric Cards & Plant Cards; `12px` for Input fields & Buttons.
* **Drop Shadow**: `0px 8px 24px rgba(0, 0, 0, 0.08)` (Soft Ambient Shadow).

---

## 📱 2. Screen-by-Screen Layout Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FIGMA SCREEN ARCHITECTURE                   │
├─────────────────┬───────────────────┬───────────────────────────┤
│ 1. Auth Flow    │ 2. Live Dashboard │ 3. Plant Profile Mgmt     │
├─────────────────┼───────────────────┼───────────────────────────┤
│ • Splash Screen │ • Header & Status │ • Registered Plant Grid   │
│ • Login Form    │ • Plant Selector  │ • Add Plant Modal Form    │
│ • Register Form │ • 2x2 Metric Grid │ • Preferences Thresholds  │
└─────────────────┴───────────────────┴───────────────────────────┘
```

---

### Screen 1: User Authentication Flow (Login / Registration)
* **Layout Structure**: Vertical Auto-Layout, Center Aligned.
* **Top Header**:
  * Brand Logo (Leaf Icon inside circular Emerald background).
  * App Title: "FloraCare Smart Monitoring".
  * Subtitle: "Real-time IoT Plant Intelligence".
* **Form Inputs**:
  * Email Input Field (Prefix icon: `mail`, Placeholder: `gardener@example.com`).
  * Password Input Field (Prefix icon: `lock`, Suffix icon: `eye_hide`).
  * Name Input Field (For Registration screen).
* **Action Buttons**:
  * Primary Button: "Sign In" / "Register Account" (Full-width, 48px height, rounded corners, Emerald gradient).
  * Toggle Text Link: "Don't have an account? Register" / "Already have an account? Login".

---

### Screen 2: Live Sensor Dashboard (Main Home Screen)
* **Layout Structure**: Scrollable Frame with Sticky Top Navigation & Fixed Bottom Navigation Bar.
* **Top Bar**:
  * User Greeting ("Welcome back, Alex! 👋").
  * Active Plant Dropdown Selector ("Living Room Monstera ▼").
  * Hardware Status Badge: Green Pulsing Dot + Text `"Hardware: ONLINE"`.
* **Hero Plant Card**:
  * Plant Thumbnail Image (Rounded 12px).
  * Plant Name & Species ("Monstera Deliciosa").
  * Target Device ID (`Node: plant_node_01`).
* **2x2 Sensor Live Grid (Real-Time Metrics)**:
  1. **Temperature Card (DHT11/22)**:
     * Icon: Thermometer Red/Orange accent.
     * Big Value: `24.5 °C`.
     * Status Pill: `Normal Range (18 - 30°C)`.
  2. **Humidity Card (DHT11/22)**:
     * Icon: Water Droplet Cyan/Blue accent.
     * Big Value: `58 %`.
     * Status Pill: `Optimal Moisture`.
  3. **Soil Moisture Card**:
     * Icon: Plant Soil Green accent.
     * Big Value: `45 %`.
     * Circular Progress Indicator / Gauge Bar.
  4. **Sunlight / LDR Card**:
     * Icon: Sun Bright Yellow accent.
     * Big Value: `72 %`.
     * Status Pill: `Bright Indirect Light`.
* **Footer Status**: "Real-time streaming active • Syncs every 5s".

---

### Screen 3: Plant Profile Management Screen
* **Layout Structure**: Vertical Stack with Floating Action Button (FAB).
* **Header**: "My Plant Collection" + Search/Filter Bar.
* **Plant List Items**:
  * Plant Card: Image, Custom Name, Species, Linked Device ID, Target Min/Max Threshold Summary.
  * Swipe Actions: Edit Preferences / Delete Plant.
* **"Add New Plant" Modal Component**:
  * Input: Plant Nickname ("Balcony Fern").
  * Input: Plant Species ("Nephrolepis exaltata").
  * Input: Device MAC / Hardware ID ("plant_node_01").
  * Slider Inputs (Set Preferences):
    * Min/Max Soil Moisture Range (e.g., 30% - 80%).
    * Min/Max Temperature Range (e.g., 18°C - 32°C).
  * Button: "Save Plant Profile".

---

## 🛠️ 3. Figma Auto-Layout Guidelines for Designers
1. **Container Padding**: Use `20px` horizontal padding for screens.
2. **Item Spacing**: Use `16px` gap for main layout stacks and `12px` gap inside metric cards.
3. **Components & Variants**: Create a master component for `MetricCard` with 4 property variants (`Temperature`, `Humidity`, `SoilMoisture`, `Sunlight`).
