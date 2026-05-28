package com.unipark.android.core.auth

import android.net.Uri

data class OIDCConfig(
    val issuerUrl: String = "https://auth.universidad.edu/realms/unipark",
    val clientId: String = "unipark-android",
    val redirectUri: Uri = Uri.parse("com.unipark.app://callback"),
)
