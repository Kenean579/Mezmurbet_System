plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))
}

android {
    namespace = "com.example.mezmurbet_admin_final1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // NOTE: Ensure this matches your Firebase Console Project exactly
        applicationId = "com.example.mezmurbet_admin_final1"
        
        // It is highly recommended to set this to 21 for just_audio compatibility
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // --- ADDED THIS BLOCK TO FIX MERGE ERRORS ---
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            merges += "META-INF/LICENSE*"
            merges += "META-INF/NOTICE*"
            merges += "META-INF/DEPENDENCIES"
        }
    }
}

flutter {
    source = "../.."
}
