# Keep annotations
-keepattributes *Annotation*

# Keep javax.annotation classes
-dontwarn javax.annotation.**
-keep class javax.annotation.** { *; }

# Keep all classes from Google Crypto Tink (if used)
-dontwarn com.google.crypto.tink.**
-keep class com.google.crypto.tink.** { *; }
