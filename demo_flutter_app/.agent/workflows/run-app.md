---
description: How to launch the Pixel 6 emulator and run the application
---

To re-run your application after closing the emulator, follow these steps:

1. **Launch the Pixel 6 Emulator**:
   Run this command in your terminal to start the emulator in the background:
   ```powershell
   Start-Process "C:\Users\vedant\AppData\Local\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd pixel_6"
   ```

2. **Wait for the device to boot**:
   Give it about 15-20 seconds to initialize.

3. **Run the Flutter App**:
   Run the following command to start your app on the emulator:
   ```powershell
   flutter run
   ```

// turbo-all
If you want me to do it for you, just ask!
