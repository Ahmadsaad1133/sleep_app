// android/app/build.gradle (module: app)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must come after Android and Kotlin plugins:
    id("dev.flutter.flutter-gradle-plugin")
    // Apply Google Services (Firebase) plugin last:
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.first_flutter_app"
    compileSdk = flutter.compileSdkVersion

    // ─── Override NDK version to satisfy Firebase plugin requirements ───
    ndkVersion = "27.0.12077973"
    // ────────────────────────────────────────────────────────────────────

    compileOptions {
        // Enable Java 11 language features
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ⚠️ Enable core-library desugaring for plugins that use newer Java APIs
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.first_flutter_app"
        minSdk = 23        // تأكد إن حد أدنى SDK لا يقل عن 21
        targetSdk = 33     // آخر نسخة متوفرة
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now, we’re using the debug keystore:
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core-library desugaring support (required by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // أي dependencies إضافية…
}
