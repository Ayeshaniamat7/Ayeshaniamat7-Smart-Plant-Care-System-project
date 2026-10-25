# Smart Plant Care System - 100% Complete Figma UI/UX Design Specification

This specification outlines the final UI/UX architecture for the complete Smart Plant Care System. It covers the fully integrated experience for sensor monitoring, AI recommendation, smart irrigation automation, alerting, and historical analytics.

---

## 🎨 1. Design System & Style Tokens

### 1.1 Color Palette
* **Primary Brand Green**: `#2E7D32` (Forest Green - headers, primary actions, active states)
* **Secondary Emerald**: `#4CAF50` (highlight accents, status pills, progress indicators)
* **Deep Background**: `#0F172A` (dark mode base)
* **Card Background**: `#1E293B` (dark cards)
* **Surface Light**: `#F8FAFC` (light mode base)
* **Warning Accent**: `#FFB300` (amber alert state)
* **Critical Accent**: `#F44336` (urgent warning / pump risk)
* **Info Accent**: `#60A5FA` (blue / analytics / neutral info)
* **Text Primary**: `#F8FAFC` (dark mode) / `#0F172A` (light mode)
* **Text Secondary**: `#94A3B8` (muted labels / helper text)
* **Success Accent**: `#22C55E` (healthy plant status)

### 1.2 Typography (Google Fonts - Inter / Outfit)
* **Heading 1 (Screen Titles)**: SemiBold 24px, Line Height 32px
* **Heading 2 (Card Titles)**: SemiBold 18px, Line Height 24px
* **Metric Display**: Bold 32px, Line Height 38px
* **Section Label**: Medium 12px, Line Height 16px
* **Body Text**: Regular 14px, Line Height 20px
* **Caption / Timestamp**: Medium 12px, Line Height 16px

### 1.3 Card & Component Elevation
* **Corner Radius**: `16px` for metric cards and plant cards; `12px` for inputs and buttons
* **Shadow**: `0px 8px 24px rgba(0, 0, 0, 0.08)`
* **Status Dot Size**: `8px` for online/alert indicators
* **Progress Ring Thickness**: `10px`

---

## 📱 2. Screen-by-Screen Layout Architecture

```text
┌───────────────────────────────────────────────────────────────────────┐
│                     FINAL FIGMA SCREEN ARCHITECTURE                  │
├───────────────────┬───────────────────────┬──────────────────────────┤
│ 1. Auth Flow      │ 2. Live Dashboard     │ 3. Plant Management      │
├───────────────────┼───────────────────────┼──────────────────────────┤
│ • Splash Screen    │ • Header + Status     │ • Plant Collection       │
│ • Login Form      │ • Sensor Grid         │ • Add/Edit Plant Form    │
│ • Register Form   │ • AI Recommendation   │ • Device Linking         │
│ • Recovery Flow   │ • Pump Control        │ • Plant Preferences     │
├───────────────────┼───────────────────────┼──────────────────────────┤
│ 4. Camera View    │ 5. Data History      │ 6. Alert Center         │
├───────────────────┼───────────────────────┼──────────────────────────┤
│ • Live Stream     │ • Trend Analytics     │ • Smart Alerts           │
│ • Plant Visual    │ • Charts & Graphs     │ • Notification Cards    │
│ • Capture State   │ • Historical Filters  │ • Recommendation Feed   │
└───────────────────┴───────────────────────┴──────────────────────────┘
```

---

### Screen 1: User Authentication Flow (Login / Registration)
* **Layout Structure**: Vertical Auto-Layout, centered composition.
* **Top Header**:
  * Brand logo: leaf icon inside emerald circle
  * App title: "FloraCare Smart Monitoring"
  * Subtitle: "Real-time IoT Plant Intelligence"
* **Form Inputs**:
  * Email input with mail icon
  * Password input with lock icon and visibility toggle
  * Name input for registration
* **Action Buttons**:
  * Primary CTA: "Sign In" / "Create Account"
  * Secondary link: "Don't have an account? Register"
  * Alternate action: "Continue as guest" (optional in final product)
* **Visual Style**:
  * Soft gradient from emerald to dark background
  * Rounded cards and elevated input fields

---

### Screen 2: Live Sensor Dashboard (Main Home Screen)
* **Layout Structure**: Scrollable frame with sticky top navigation and bottom navigation.
* **Top Bar**:
  * Greeting: "Welcome back, Alex! 👋"
  * Active plant selector dropdown
  * Device status badge: green dot + "Hardware: ONLINE"
* **Hero Plant Card**:
  * Plant image thumbnail
  * Plant name and species
  * Device ID: `Node: plant_node_01`
  * Quick health status pill: `Healthy / Warning / Critical`
* **2x2 Sensor Live Grid**:
  1. **Temperature Card**:
     * Value: `24.5 °C`
     * Status: `Normal Range (18 - 30°C)`
  2. **Humidity Card**:
     * Value: `58 %`
     * Status: `Optimal Moisture`
  3. **Soil Moisture Card**:
     * Value: `45 %`
     * Circular gauge and progress bar
  4. **Sunlight Card**:
     * Value: `72 %`
     * Status: `Bright Indirect Light`
* **AI Insight Panel**:
  * "AI Recommendation" banner
  * Short text: "Plant is healthy. Maintain current moisture range."
  * Confidence indicator with percentage
  * Suggestion CTA: "View full insight"
* **Footer Status**: "Real-time streaming active • Syncs every 5s"

---

### Screen 3: Plant Profile Management Screen
* **Layout Structure**: Vertical stack with floating action button.
* **Header**: "My Plant Collection"
* **Search / Filter Row**: plant search, filter by condition, sort by device
* **Plant List Items**:
  * Plant image
  * Nickname and species
  * Linked device ID
  * Healthy range summary
  * Status badge
* **Add / Edit Plant Modal**:
  * Plant nickname field
  * Species field
  * Linked device ID
  * Min/Max moisture range
  * Min/Max temperature range
  * Min/Max light range
  * Save button
* **Actions**:
  * Edit thresholds
  * Delete plant
  * Reconnect device

---

### Screen 4: AI Recommendation & Smart Alert Center
* **Layout Structure**: Tabbed screen with summary and detail panels.
* **Header**: "AI Care Recommendations"
* **Recommendation Cards**:
  * Health diagnosis
  * Watering amount
  * Pump duration estimate
  * Next watering time
* **Alert Cards**:
  * `WARNING`: Low soil moisture
  * `CRITICAL`: Heat stress detected
  * `INFO`: Optimal conditions
* **Buttons**:
  * "Run Analysis"
  * "Water Now"
  * "View Details"
* **AI Data Visualization**:
  * Confidence bar or donut chart
  * status labels
  * recommendation text block

---

### Screen 5: Camera Live View
* **Layout Structure**: Full-width live camera feed with overlaid controls.
* **Header**:
  * Plant camera title
  * Live device indicator
  * Snapshot button
* **Live Preview Area**:
  * ESP32 camera feed
  * Plant visual status overlay
  * status chips for humidity, light, and moisture
* **Control Actions**:
  * Capture image
  * Focus toggle
  * Zoom / fit view
  * Switch camera
* **Lower Panel**:
  * visual health summary
  * last synced time
  * notes like "Leaf color healthy, soil slightly dry"

---

### Screen 6: Sensor History & Data Visualization
* **Layout Structure**: Multi-panel analytics screen.
* **Header**:
  * "Plant Health History"
  * Date range selector: 24h / 7d / 30d
* **Chart Area**:
  * temperature line chart
  * humidity line chart
  * soil moisture chart
  * sunlight chart
* **Insights Summary**:
  * Average temperature
  * Average moisture
  * healthiest period
  * lowest hydration period
* **Filter Chips**:
  * Temperature
  * Humidity
  * Soil Moisture
  * Light
* **Summary Footer**:
  * "Last 7 days trend: stable and healthy"

---

### Screen 7: Smart Irrigation Control Panel
* **Layout Structure**: Card-based control dashboard.
* **Header**: "Watering Control"
* **Current Status Panel**:
  * Pump state: `OFF` / `AUTO` / `MANUAL`
  * Last watering time
  * Pump runtime
* **Manual Action Card**:
  * Button: "Water 5s"
  * Button: "Water 10s"
  * Button: "Stop Pump"
* **Automation Section**:
  * Auto mode toggle
  * Minimum moisture threshold slider
  * Trigger threshold field
* **Safety Info**:
  * Pump protection notice
  * Water usage summary

---

## 🛠️ 3. Final Figma Auto-Layout Guidelines

1. **Container Padding**: use `20px` horizontal padding for main screens.
2. **Item Spacing**: use `16px` for section separation and `12px` inside cards.
3. **Component Variants**:
   * `MetricCard` variants: Temperature, Humidity, Soil Moisture, Light
   * `AlertCard` variants: Info, Warning, Critical
   * `CTAButton` variants: Primary, Secondary, Danger
4. **Grid System**:
   * use 12-column grid for desktop or large tablet mockups
   * use 4-column grid for mobile design
5. **Responsive Rules**:
   * cards stack vertically on smaller screens
   * charts compress smoothly without losing readability
   * camera feed should maintain 16:9 orientation
6. **Accessibility**:
   * minimum button height: `48px`
   * high contrast text on dark surfaces
   * clear visual distinction for warning and critical states

---

## 🧩 4. Core UI Components

### 4.1 Metric Card
* Title
* Icon
* Large value
* Status pill
* Trend indicator (optional)

### 4.2 Alert Card
* Icon: exclamation / check / info
* Title and subtitle
* Severity color bar
* Action button

### 4.3 Plant Card
* Thumbnail image
* Nickname
* Species
* Device ID
* Status indicator
* Quick action menu

### 4.4 Chart Panel
* Title
* Date filters
* Graph with axis labels
* Summary insight below

### 4.5 AI Recommendation Banner
* Recommendation title
* Confidence status
* Quick action CTA
* Health badge

---

## 📐 5. Final Design Principles

* Keep the interface clean, calm, and plant-focused
* Use green as the primary product color for health and trust
* Distinguish warning and critical states immediately through color and motion
* Prioritize readability of sensor data and recommendation actions
* Make AI suggestions actionable and easy to understand
* Ensure the app feels premium but friendly and functional for everyday users

---

## ✅ 6. Final Product Summary

This design specification represents the complete Smart Plant Care System UI/UX for a fully integrated product:

- real-time monitoring
- AI diagnosis and recommendation engine
- automated watering control
- camera-based visual monitoring
- history and analytics
- automated alerts and notifications

The final interface is designed to feel modern, intuitive, and trustworthy for plant owners using a connected smart gardening system.
