<!-- @format -->

# Production Test Strategy for Runify

## Overview

This document outlines the testing strategy for Runify, an app already published
on the App Store. The tests focus on **preventing regressions**, **ensuring data
integrity**, and **catching edge cases** that could cause crashes or data loss.

## Test Categories

### 1. Critical Path Tests ✅

**Priority: CRITICAL**

Tests the main user journey that must work for the app to be functional:

- Complete run lifecycle (start → track → save)
- Minimal valid run scenarios
- Run save validation

**Why it matters:** If these break, users can't track runs - the core
functionality fails.

### 2. Data Integrity Tests ✅

**Priority: CRITICAL**

Ensures data is never lost or corrupted:

- Run data persistence (encoding/decoding)
- SharedRunData persistence (critical for widget)
- Multiple runs sorting and limiting
- Run update preserves existing data

**Why it matters:** Data loss is the #1 user complaint. These tests prevent:

- Runs not saving to SwiftData
- Widget showing incorrect data
- Data corruption during updates

### 3. Pace Calculation Tests ✅

**Priority: HIGH**

Validates the accuracy of pace calculations:

- Pace calculation accuracy
- Zero distance handling
- Very short duration handling
- Pace formatting for display

**Why it matters:** Users rely on pace data for training. Incorrect calculations
erode trust.

### 4. Distance Calculation Tests ✅

**Priority: HIGH**

Ensures distance tracking is accurate:

- Distance between coordinates
- Distance formatting (user-facing)
- Distance conversions (km ↔ miles)

**Why it matters:** Distance is a core metric. Errors here make the app
unreliable.

### 5. Location Validation Tests ✅

**Priority: HIGH**

Prevents bad GPS data from corrupting runs:

- Coordinate validation filters invalid data
- Sequence indices preserve route order

**Why it matters:** Bad GPS data can cause:

- Incorrect distance calculations
- Route visualization errors
- App crashes

### 6. State Management Tests ✅

**Priority: MEDIUM**

Tests navigation and state transitions:

- AppCoordinator navigation state
- Planned route management
- Run favorite toggle state

**Why it matters:** Broken state management causes:

- Navigation bugs
- UI inconsistencies
- User confusion

### 7. Edge Case Tests ✅

**Priority: MEDIUM**

Prevents crashes from unexpected inputs:

- Maximum realistic values (ultra marathons)
- Large coordinate arrays (performance)
- Empty location names
- Time formatting edge cases
- Map region calculation edge cases

**Why it matters:** Edge cases cause crashes that lead to 1-star reviews.

### 8. Data Migration Tests ✅

**Priority: LOW (but important for updates)**

Ensures backward compatibility:

- SharedRunData backward compatibility
- Run with optional fields

**Why it matters:** When you update the app, existing users' data must still
work.

## Test Coverage Summary

| Category              | Tests  | Priority | Status |
| --------------------- | ------ | -------- | ------ |
| Critical Path         | 3      | CRITICAL | ✅     |
| Data Integrity        | 4      | CRITICAL | ✅     |
| Pace Calculations     | 4      | HIGH     | ✅     |
| Distance Calculations | 3      | HIGH     | ✅     |
| Location Validation   | 2      | HIGH     | ✅     |
| State Management      | 3      | MEDIUM   | ✅     |
| Edge Cases            | 5      | MEDIUM   | ✅     |
| Data Migration        | 2      | LOW      | ✅     |
| **TOTAL**             | **26** |          | ✅     |

## Running the Tests

### In Xcode

1. Press `Cmd+U` to run all tests
2. Use Test Navigator (⌘6) to run specific test suites
3. Right-click on a test to run just that test

### From Command Line

```bash
xcodebuild test -scheme Runify -destination 'platform=iOS Simulator,name=iPhone 15'
```

## What's NOT Tested (Yet)

These require mocking or integration testing:

1. **RunTracker Integration Tests**

   - Requires mocking `CLLocationManager`
   - Tests actual GPS tracking flow
   - Tests pause/resume during run

2. **HealthKit Integration**

   - Requires HealthKit framework mocking
   - Tests calorie tracking
   - Tests workout session management

3. **Live Activity Tests**

   - Requires ActivityKit mocking
   - Tests Live Activity updates
   - Tests Dynamic Island updates

4. **Network Tests**

   - Requires network mocking
   - Tests Google Maps Places API
   - Tests route calculation

5. **UI Tests**
   - Requires UI testing framework
   - Tests user interactions
   - Tests view state changes

## Recommendations for Future Testing

1. **Add Integration Tests** for `RunTracker` with mocked location manager
2. **Add Performance Tests** for map region calculation with 10,000+ coordinates
3. **Add UI Tests** for critical user flows (start run, view history)
4. **Add Snapshot Tests** for view components to catch UI regressions
5. **Add Accessibility Tests** to ensure app works with VoiceOver

## Test Maintenance

- **Run tests before every commit** to catch regressions early
- **Add tests when fixing bugs** to prevent regressions
- **Update tests when adding features** to maintain coverage
- **Review test failures immediately** - they indicate real issues

## Success Metrics

A good test suite should:

- ✅ Catch bugs before they reach production
- ✅ Give confidence when refactoring
- ✅ Document expected behavior
- ✅ Run quickly (< 30 seconds for all tests)
- ✅ Be easy to understand and maintain

---

**Last Updated:** 2025-01-27 **Test Framework:** Swift Testing (iOS 18+)
