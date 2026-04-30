# App Store Connect — Review Notes Template

Paste this into the "Notes" field on the App Review Information page before submitting.

---

## Demo / Reviewer Credentials

**Phone:** +91 98765 43210
**OTP:** 949999

This is a Firebase test phone number registered under Authentication → Sign-in method → Phone → Test phone numbers in our Firebase Console. When the reviewer enters this phone number on the login screen, the OTP field auto-fills with 949999 and signs in automatically — no SMS required.

---

## App Overview

Auramika Daily is a jewelry e-commerce app (physical goods) with:

- **Browse & Buy**: Catalog → product detail → cart → Cashfree checkout (physical goods; Apple IAP not applicable)
- **Magic Mirror (AI Stylist)**: Upload an outfit photo; GPT-4o matches a jewelry recommendation. Requires explicit in-app consent before any photo leaves the device.
- **Express Delivery**: Products tagged ⚡ are available for 2-hour local delivery in Mumbai.
- **Account**: Phone-OTP login via Firebase Auth; full account deletion available under Profile → Delete Account.

---

## Payment Flow

The app uses Cashfree Payment Gateway for physical goods. Production mode is active for the review build. To exercise checkout without completing a real payment, use Cashfree's test card:

- Card: 4111 1111 1111 1111 | Exp: any future date | CVV: any 3 digits

---

## AI Stylist Feature

- User photo is sent to OpenAI (api.openai.com) only after explicit consent via an in-app consent sheet.
- Photo is not stored on our servers or retained by OpenAI after processing.
- Consent can be withdrawn at any time via Profile → AI Stylist Settings.
- The feature is suppressed for China mainland (device locale CN). China mainland has been deselected in App Store Connect → Pricing & Availability.

---

## Backend

Live at https://auramikadaily.com — accessible 24/7 during the review period.

---

## China Distribution

**Action required before submission:** In App Store Connect → Pricing and Availability, deselect "China mainland". The app uses OpenAI which does not hold a MIIT/DST permit for China. Runtime locale gate is also in place as a belt-and-suspenders measure.
