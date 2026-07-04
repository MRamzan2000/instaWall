# Meta Audience Network
-keep class com.facebook.ads.** { *; }
-keep class com.facebook.** { *; }
-dontwarn com.facebook.ads.internal.**
-dontwarn com.facebook.infer.annotation.Nullsafe
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode

# Keep all classes from Audience Network SDK
-keep class com.facebook.ads.** { *; }
-keepclassmembers class com.facebook.ads.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}