plugins {
    id("com.android.application")
    id("kotlin-android")
    // ✅ Flutter Gradle plugin
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Firebase services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.neuro_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.neuro_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ❗Replace this with a release key before publishing
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Updated to 2.1.4
}
