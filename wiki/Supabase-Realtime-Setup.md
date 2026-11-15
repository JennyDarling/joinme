# Supabase Realtime Setup Guide

JoinMe uses **Supabase Realtime** for sub-100ms peer synchronization, chat messaging, and presence indicators.

---

## 1. Creating a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in (or create a free account).
2. Click **New Project**.
3. Choose a name (e.g. `JoinMe-Realtime`), set a database password, and pick a region close to your target users.
4. Wait approximately 1-2 minutes for project provisioning to complete.

---

## 2. Obtaining Your Credentials

1. In the Supabase project dashboard, navigate to **Project Settings** (the gear icon on the left sidebar).
2. Click on the **API** tab.
3. Locate the **Project URL** (e.g. `https://xyzabcdefg.supabase.co`).
4. Locate the **Project API Keys** section and copy the **`anon` / `public`** key.
   > [!IMPORTANT]
   > Do **NOT** copy the `service_role` key! The `service_role` key must remain confidential and is never used in mobile client apps.

---

## 3. Configuring JoinMe

### In-App Configuration (Easiest)
1. Launch JoinMe on your device or simulator.
2. Tap the **Settings (gear)** icon on the top right of the home screen.
3. Paste your **Supabase Project URL** and **Anon Key**.
4. Tap **Save Configuration**.

Your settings are securely persisted in local device storage and used for all future rooms.
