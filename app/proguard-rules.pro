# Keep JNI callback interface (called from native code)
-keep class com.airback.bridge.RaopCallbackHandler { *; }
-keep class * implements com.airback.bridge.RaopCallbackHandler { *; }
-keep class com.airback.bridge.LogListener { *; }
-keep class * implements com.airback.bridge.LogListener { *; }

# Keep NativeBridge native methods
-keep class com.airback.bridge.NativeBridge { *; }
