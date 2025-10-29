# Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Google Pay (used internally by Razorpay)
-keep class com.google.android.apps.nbu.paisa.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.**

# Play Core (used by Flutter deferred components)
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Annotation fixes
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep your MainActivity to prevent it being stripped
-keep class com.download.school_pdf.MainActivity { *; }
