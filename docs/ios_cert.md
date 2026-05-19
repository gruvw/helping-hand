# iOS Certificate Install

Installing a custom certificate on iOS is a three-part process: downloading it, installing the profile, and manually trusting it.

**Step 1**: Download the Certificate

Open Safari and navigate to the link or portal where your certificate is hosted.

Tap the link to download the certificate file.

A pop-up will say, "This website is trying to download a configuration profile." Tap Allow.

A second pop-up will confirm the profile has downloaded. Tap Close.

**Step 2**: Install the Profile

Open your iPhone's Settings app.

Near the top (just under your Apple ID), tap Profile Downloaded.

Tap Install in the top-right corner.

Enter your iPhone passcode when prompted.

You may see a warning screen. Tap Install in the top-right corner, and then tap Install again at the bottom of the screen to confirm.

Tap Done.

**Step 3**: Enable Full Trust (Crucial for Root Certificates)

Note: iOS does not automatically trust manually installed root certificates for SSL/TLS connections. You must enable this manually.
+1

In the Settings app, go to General > About.

Scroll to the very bottom and tap Certificate Trust Settings.

Look under the Enable full trust for root certificates section.

Find the certificate you just installed and toggle the switch to the ON (green) position.

Tap Continue on the prompt confirming you want to trust the certificate.

(If you are installing a certificate issued by a school or employer, they may use Mobile Device Management (MDM) to push the certificate to your phone automatically, in which case you won't need to do this manually.)

# Uninstall iOS Certificate

How to Remove a Profile on iOS

1. Open the Settings app on your iPhone or iPad.
2. Tap on General.
3. Scroll down and tap on VPN & Device Management (on older iOS versions, this may just be called Profiles or Profiles & Device Management).
4. Under the Configuration Profile section, tap the name of the certificate you want to remove.
5. Tap Remove Profile.
6 Enter your device passcode if prompted, and confirm the removal.
