# Sceneform ProGuard rules
-dontwarn com.google.ar.sceneform.animation.AnimationEngine
-dontwarn com.google.ar.sceneform.animation.AnimationLibraryLoader
-dontwarn com.google.ar.sceneform.assets.Loader
-dontwarn com.google.ar.sceneform.assets.ModelData
-dontwarn com.google.devtools.build.android.desugar.runtime.ThrowableExtension

# Keep Sceneform classes to avoid missing class errors
-keep class com.google.ar.sceneform.** { *; }
-keep interface com.google.ar.sceneform.** { *; }

# Also keep ARCore classes if needed
-keep class com.google.ar.core.** { *; }
-keep interface com.google.ar.core.** { *; }
