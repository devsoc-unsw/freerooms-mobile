plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    id("dev.detekt") version("2.0.0-alpha.2")
    alias(libs.plugins.apollo)
}

detekt {
    buildUponDefaultConfig = true
}

android {
    namespace = "com.devsoc.freerooms"
    compileSdk {
        version = release(36) {
            minorApiLevel = 1
        }
    }

    defaultConfig {
        applicationId = "com.devsoc.freerooms"
        minSdk = 29
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    buildFeatures {
        compose = true
    }
}

apollo {
    service("service") {
        packageName.set("com.devsoc.freerooms")

        // Map custom scalars. _text is a list in Postgres/Hasura.
        mapScalar("_text", "kotlin.Any")
        mapScalar("_varchar", "kotlin.String")
        mapScalar("float8", "kotlin.Double")
        mapScalar("timestamptz", "kotlin.String")
        mapScalar("bookingtypeenum", "kotlin.String")
        mapScalar("floortypeenum", "kotlin.String")
        mapScalar("seatingtypeenum", "kotlin.String")
        mapScalar("status_enum", "kotlin.String")
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    testImplementation(libs.junit)
    testImplementation(libs.mockk)
    testImplementation(libs.okhttp.mockwebserver)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    detektPlugins(libs.detekt.compose.rules)

    // Apollo
    implementation(libs.apollo.runtime)
    
    // OkHttp for logging
    implementation(platform(libs.okhttp.bom))
    implementation(libs.okhttp)
    implementation(libs.okhttp.logging)
}