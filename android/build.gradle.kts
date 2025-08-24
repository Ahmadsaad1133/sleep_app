// ─────────────────────────────────────────────────────────────────────────────
// REMOVE any `plugins { id("com.android.application") version "…" }` here.
// Instead, use buildscript { … } to pull in both the Android Gradle Plugin (AGP)
// and the Google Services (Firebase) plugin on the classpath.
// ─────────────────────────────────────────────────────────────────────────────

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Make sure this matches the AGP version that Gradle already has
        // (your error said “already on the classpath with 8.7.0”).
        classpath("com.android.tools.build:gradle:8.7.0")

        // Add the Firebase “google-services” Gradle plugin here:
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Your existing “newBuildDir” / “subprojects” / “clean” tasks can remain unchanged.)

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
