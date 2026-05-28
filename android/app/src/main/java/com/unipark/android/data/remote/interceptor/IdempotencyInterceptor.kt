package com.unipark.android.data.remote.interceptor

import okhttp3.Interceptor
import okhttp3.Response
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class IdempotencyInterceptor @Inject constructor() : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()
        
        return if (originalRequest.method == "POST") {
            val idempotencyKey = UUID.randomUUID().toString()
            val modifiedRequest = originalRequest.newBuilder()
                .header("Idempotency-Key", idempotencyKey)
                .build()
            chain.proceed(modifiedRequest)
        } else {
            chain.proceed(originalRequest)
        }
    }
}
