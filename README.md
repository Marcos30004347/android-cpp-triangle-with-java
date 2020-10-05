Example of an android app that uses cpp using just the SDK and the NDK to build the final APK.


dependencies:
    - Android SDK
    - Android NDK


"build.sh" requires you to set ANDROID_SDK env variable to the path that you have installed the Android SDK. "cmake/android.cmake" also needs ANDROID_NDK env variable to be the place that you have installed the Android NDK.

To build the apk run:
$ ./keystool.sh
$ ./build.sh

The apk will be in the build/ directory

references:
https://www.hanshq.net/command-line-android.html
https://github.com/hunter-packages/android-apk