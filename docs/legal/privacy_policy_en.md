# Chi Wise Magic Privacy Policy

**Last updated:** [publish date]

Chi Wise Magic ("the app", "we") helps you make decisions using the
Cartesian Square method and the Magic Ball. This Policy explains what data
we collect, why, and how you can have it deleted.

> ⚠️ This is a draft prepared directly from the app's actual code. Before
> publishing, please have a lawyer review it (especially the GDPR and
> age-rating sections), fill in the date, and put the final Policy URL into
> App Store Connect / Google Play Console.

## 1. Data we collect

### 1.1. Account data
Signing in with **Google** or **Apple** gives us the name and email they
provide (Apple may hide your real email via Private Relay — that's your
choice in the sign-in dialog). Signing in **anonymously** requests no
personal data — a random device-tied identifier is created instead.

### 1.2. Profile and progress data
Stored in Cloud Firestore, tied to your account: interface language,
number of decisions made, current location on the map, day streak, Magic
Ball energy and usage count, subscription status, unlocked achievements,
your "Mindfulness Scale" level.

### 1.3. Your decisions (the most sensitive part)
The text of your doubts, all four Cartesian Square answers, your final
decision in your own words, and the category you pick — saved to your
account so you can revisit them. We don't read or manually analyze this
content; it's used only to display it back to you and for usage statistics
(e.g. how many characters you wrote — not the text itself).

### 1.4. Purchases and subscription
Processed through RevenueCat, the App Store, or Google Play — we never see
or store card numbers. We only receive subscription status and product id.

### 1.5. Technical data
- **Usage analytics** (Firebase Analytics): which screens/features are
  used, without the content of your decisions.
- **Crash reports** (Firebase Crashlytics): technical error diagnostics.
- **Accelerometer** — used only locally on-device for the Magic Ball's
  "shake" animation, never transmitted anywhere.

We **do not show ads** and **do not use any third-party
advertising/tracking SDKs**.

## 2. Why we use this data

- To run the app and keep your progress in sync across devices.
- To manage your subscription and purchase history.
- To find and fix bugs (Crashlytics).
- To understand which features are used (aggregated analytics).

We do not sell your data to third parties or use it for ad targeting.

## 3. Who we share data with

Only service providers that process data on our behalf:

| Service | Purpose |
|---|---|
| Google Firebase (Auth, Firestore, Analytics, Crashlytics) | Account, data storage, analytics, crash reporting |
| RevenueCat | Subscription management |
| Apple / Google | Sign-in, in-store payment processing |

Each of them handles data under its own privacy policy.

## 4. Data retention and deletion

We keep your data as long as you have an account. **In-app:** open
Settings → "Delete account" to permanently remove your account and all
associated data immediately. **By email:** you can also write to
**egorova.esp@gmail.com** with subject "Account deletion" and we'll delete
it within [state a timeframe, e.g. 30 days].

## 5. Children

The app is not directed at children under 13 (or 16 in the EU, depending
on jurisdiction) and does not knowingly collect data from minors.

## 6. Your rights (GDPR and similar laws)

If you're in the EU/EEA, you have the right to access, correct, delete,
and port your data, and to withdraw consent. Use the deletion methods
above, or contact us for anything else.

## 7. Changes to this Policy

We may update this Policy. Material changes will be reflected by the
"last updated" date at the top.

## 8. Contact

Privacy questions: **egorova.esp@gmail.com**
