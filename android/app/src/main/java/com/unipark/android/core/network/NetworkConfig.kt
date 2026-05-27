package com.unipark.android.core.network

data class NetworkConfig(
    val baseUrl: String = "https://api.unipark.edu/v1/",
    val webSocketUrl: String = "wss://api.unipark.edu/ws",
)
