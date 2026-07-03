# macOS Sequoia Virtualization Setup

This directory contains configuration files to automate building a macOS Sequoia (macOS 15) guest virtual machine in VMware Fusion using Packer.

## Guest OS Installation Steps

Since macOS does not support pre-seeding the post-install Setup Assistant, you must complete the initial GUI configuration manually once the VM finishes copying files and reboots.

### 1. Complete the Setup Assistant
When the VM boots into the macOS Setup Assistant, walk through the screens:
1. **Region & Language**: Select your preferred region and keyboard.
2. **Accessibility**: Click **Not Now** (or Customize if needed).
3. **Data & Privacy**: Click **Continue**.
4. **Migration Assistant**: Click **Not Now**.
5. **Sign In with Apple ID**: Click **Set Up Later**, then confirm **Skip**.
6. **Terms and Conditions**: Click **Agree**.
7. **Create a Computer Account** (CRITICAL):
   - **Full name**: `vagrant`
   - **Account name**: `vagrant`
   - **Password**: `vagrant`
   - **Hint**: `vagrant`
8. **Enable Location Services**: Click **Continue** or disable it.
9. **Time Zone**: Select your time zone.
10. **Analytics**: Uncheck and click **Continue**.
11. **Screen Time**: Click **Set Up Later**.
12. **Siri**: Disable or continue.
13. **Appearance**: Choose Dark/Light/Auto and click **Continue**.

---

### 2. Enable Remote Login (SSH)
Once you reach the desktop, you must enable SSH so Packer can connect and run the provisioners:
1. Open **System Settings**.
2. Navigate to **General** > **Sharing**.
3. Toggle **Remote Login** to **ON**.
4. Allow access for **All Users** or specifically the `vagrant` user.

Once Remote Login is enabled, Packer will automatically detect the active SSH session, connect, and complete the VM provisioning.
