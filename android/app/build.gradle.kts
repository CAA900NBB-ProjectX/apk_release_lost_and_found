plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.found_it_frontend_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Ensure this is set correctly

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

//    kotlinOptions {
//        jvmTarget = JavaVersion.VERSION_11.toString()
//    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.found_it_frontend_new"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ✅ Correct Kotlin DSL syntax for product flavors
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.example.found_it_frontend.dev"
            versionNameSuffix = "-dev"
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.example.found_it_frontend"
        }
    }
}

flutter {
    source = "../.."
}
