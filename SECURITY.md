# Security Policy

The JoinMe team and contributors take the security and privacy of our users very seriously. We appreciate your efforts to responsibly disclose vulnerabilities to help us keep the platform safe for everyone.

---

## 🛡️ Supported Versions

The following versions of JoinMe currently receive security updates and patches:

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 1.0.x   | :white_check_mark: | Active Support |
| < 1.0.0 | :x:                | Deprecated / End of Life |

---

## 📬 Reporting a Vulnerability

If you discover a potential security vulnerability within JoinMe, please **do NOT report it via public GitHub issues or public discussions**.

### How to Report Privately:
1. **GitHub Private Vulnerability Advisory:**
   - Go to the **Security** tab of the [JennyDarling/joinme](https://github.com/JennyDarling/joinme) repository.
   - Click on **Report a vulnerability** to submit a private report directly to repository maintainers.
2. **Email Disclosure:**
   - You can also reach out via email to `261972903+JennyDarling@users.noreply.github.com` with the subject `[SECURITY] JoinMe Vulnerability Report`.

### What to Include in Your Report:
To help us triage and investigate the issue quickly, please provide:
- A detailed description of the vulnerability and its potential impact.
- Step-by-step instructions or a minimal Proof of Concept (PoC) to reproduce the issue.
- The platform, OS version, and app release version where the vulnerability was observed.
- Any suggested fixes or remediation strategies, if available.

### Response Time & Disclosure Timeline:
- **Initial Acknowledgment:** Within **48 hours** of receiving the report.
- **Triage & Assessment:** Within **5 business days**, detailing validation and severity score (CVSS).
- **Patch Release:** Security patches will be prioritized and published in a point release.
- **Public Disclosure:** Coordinated public disclosure will take place only after a verified fix has been released to users.

---

## 🔒 Security Architecture & Best Practices

JoinMe was architected with data minimization and peer privacy at its core:

### 1. Supabase API Keys & Data Privacy
- **Public Anon Key Only:** JoinMe clients only require the public `anon` key to subscribe to ephemeral Realtime channels (`broadcast` and `presence`).
- **Never Use Service Role Keys:** Do **never** hardcode or bundle your Supabase `service_role` (admin) secret key into the mobile application binaries. The `service_role` key bypasses all Row Level Security and should only reside on trusted backend servers.
- **Ephemeral Channel Design:** Room chat messages and live reactions are ephemeral broadcast payloads and are not stored permanently unless explicitly persisted by your own backend schema.

### 2. WebRTC Peer-to-Peer Encryption
- Audio streams exchanged during voice calls connect directly between devices via WebRTC.
- Media traffic is end-to-end encrypted using **DTLS-SRTP** (Datagram Transport Layer Security / Secure Real-time Transport Protocol).
- Voice data does not route through or get stored on any intermediary application servers.

### 3. Device Permissions & Microphone Access
- **Microphone Access (`RECORD_AUDIO` / `NSMicrophoneUsageDescription`):** Microphone access is requested solely for active real-time voice calls initiated by the user.
- **No Background Recording:** The application never records, intercepts, or transmits microphone data outside of an explicit, user-initiated voice chat session.
- **Clear Indicator:** When in an active call, a visual status indicator is prominently displayed in the app UI, and users can mute their microphone at any time.

### 4. Local Storage
- Local storage (`SharedPreferences` / `NSUserDefaults`) only retains the user's chosen display name and user ID for convenience. No sensitive credentials or passwords are saved locally.

---

Thank you for helping us keep JoinMe safe and secure!
