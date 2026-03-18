<<<<<<< HEAD
# ARCore Rules
-keep class com.google.ar.core.** { *; }
-dontwarn com.google.ar.core.**

# Sceneform Rules
-keep class com.google.ar.sceneform.** { *; }
-dontwarn com.google.ar.sceneform.**

# General rules for Sceneform animation and assets (from missing_rules.txt)
=======
# Sceneform ProGuard rules
>>>>>>> 3478406f6cdf5db1b206697d5614374e5831fb9c
-dontwarn com.google.ar.sceneform.animation.AnimationEngine
-dontwarn com.google.ar.sceneform.animation.AnimationLibraryLoader
-dontwarn com.google.ar.sceneform.assets.Loader
-dontwarn com.google.ar.sceneform.assets.ModelData
-dontwarn com.google.devtools.build.android.desugar.runtime.ThrowableExtension

<<<<<<< HEAD
# Flutter ProGuard rules (standard)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core rules
-keep class com.google.android.play.core.common.IntentSenderForResultHelper { *; }
-keep class com.google.android.play.core.release_notes.CompatibilityCheck { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.install.** { *; }
-dontwarn com.google.android.play.core.**

# AndroidX Core lStar warning suppression (if applicable)
-dontwarn androidx.core.view.ViewCompat$Api31Impl
=======
# Keep Sceneform classes to avoid missing class errors
-keep class com.google.ar.sceneform.** { *; }
-keep interface com.google.ar.sceneform.** { *; }

# Also keep ARCore classes if needed
-keep class com.google.ar.core.** { *; }
-keep interface com.google.ar.core.** { *; }
>>>>>>> 3478406f6cdf5db1b206697d5614374e5831fb9c
