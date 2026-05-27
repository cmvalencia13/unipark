package com.unipark.android.core.network

import com.squareup.moshi.Moshi
import com.unipark.android.core.auth.TokenStorage
import com.unipark.android.data.remote.LotOccupancyUpdateDto
import com.unipark.android.data.remote.toDomain
import com.unipark.android.domain.entities.LotOccupancyUpdate
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class OccupancyWebSocketClient @Inject constructor(
    private val okHttpClient: OkHttpClient,
    private val tokenStorage: TokenStorage,
    private val networkConfig: NetworkConfig,
    moshi: Moshi,
) {
    private val adapter = moshi.adapter(LotOccupancyUpdateDto::class.java)

    fun observe(): Flow<LotOccupancyUpdate> = callbackFlow {
        val requestBuilder = Request.Builder().url(networkConfig.webSocketUrl)
        tokenStorage.getAccessToken()?.let { token ->
            requestBuilder.addHeader("Authorization", "Bearer $token")
        }

        val webSocket = okHttpClient.newWebSocket(
            requestBuilder.build(),
            object : WebSocketListener() {
                override fun onMessage(webSocket: WebSocket, text: String) {
                    adapter.fromJson(text)?.toDomain()?.let { trySend(it) }
                }

                override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                    close(t)
                }
            },
        )

        awaitClose { webSocket.close(1000, "closed") }
    }
}
