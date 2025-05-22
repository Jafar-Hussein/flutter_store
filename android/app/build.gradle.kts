plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // Flutter plugin ska alltid ligga sist
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_store"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // ✅ exakt NDK-version krävs

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.flutter_store"
        minSdk = 23 // ✅ höjd till 23 enligt Firebase-krav
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
