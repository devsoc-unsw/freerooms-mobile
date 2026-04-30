plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.apollo)
}

android {
    namespace = "com.devsoc.freerooms.core.network"
    compileSdk = 36

    defaultConfig {
        minSdk = 29
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

apollo {
    service("service") {
        introspection {
            endpointUrl.set("https://graphql.devsoc.app/v1/graphql")
            schemaFile.set(file("src/main/graphql/schema.graphqls"))
        }
        packageName.set("com.devsoc.freerooms.network")
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
    "api"(libs.apollo.runtime)
    "api"(libs.apollo.api)
    implementation(platform(libs.okhttp.bom))
    "api"(libs.okhttp)
    "api"(libs.okhttp.logging)

    testImplementation(libs.junit)
    testImplementation(libs.mockk)
    testImplementation(libs.okhttp.mockwebserver)
}
