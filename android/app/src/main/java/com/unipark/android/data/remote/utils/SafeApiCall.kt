package com.unipark.android.data.remote.utils

import com.squareup.moshi.Moshi
import com.unipark.android.domain.model.Resource
import retrofit2.Response

suspend fun <T, R> safeApiCall(
    moshi: Moshi,
    apiCall: suspend () -> Response<T>,
    transform: (T) -> R
): Resource<R> {
    return try {
        val response = apiCall()
        if (response.isSuccessful) {
            val body = response.body()
            if (body != null) {
                Resource.Success(transform(body))
            } else {
                Resource.Error("Response body was empty", status = response.code())
            }
        } else {
            val errorBody = response.errorBody()?.string()
            if (!errorBody.isNullOrBlank()) {
                try {
                    // Try to parse as RFC 7807 problem details
                    val adapter = moshi.adapter(Map::class.java)
                    val errorMap = adapter.fromJson(errorBody)
                    val title = errorMap?.get("title")?.toString()
                    val detail = errorMap?.get("detail")?.toString()
                    val type = errorMap?.get("type")?.toString()
                    val status = (errorMap?.get("status") as? Double)?.toInt() 
                        ?: response.code()
                    Resource.Error(
                        message = detail ?: title ?: "API Error",
                        title = title,
                        status = status,
                        type = type,
                        detail = detail
                    )
                } catch (e: Exception) {
                    Resource.Error(
                        message = "Error code: ${response.code()}",
                        status = response.code()
                    )
                }
            } else {
                Resource.Error(
                    message = "Error code: ${response.code()}",
                    status = response.code()
                )
            }
        }
    } catch (e: Exception) {
        Resource.Error(message = e.localizedMessage ?: "Unknown network error")
    }
}
