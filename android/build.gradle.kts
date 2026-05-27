plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.kotlin.parcelize) apply false
    alias(libs.plugins.hilt) apply false
    alias(libs.plugins.ksp) apply false
}

val externalBuildRoot = System.getenv("UNIPARK_ANDROID_BUILD_DIR")
if (!externalBuildRoot.isNullOrBlank()) {
    allprojects {
        val projectDirName = path.removePrefix(":").ifBlank { "root" }.replace(':', '_')
        layout.buildDirectory.set(file("$externalBuildRoot/$projectDirName"))
    }
}
