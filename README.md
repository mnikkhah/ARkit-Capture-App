# ARkit-Capture-App
A simple iOS app to capture and save ARkit frames (Images and Camera Transform matrix)

This app captures ARKit frames at the default resolution (1242 × 2586) in PNG format, along with the camera transform (Rotation + Translation matrix) and saves them in a txt file (row-order). In order to let the app save these files on device, you need to go to the app's info.plist and add `Application supports iTunes file sharing` as `YES`.
