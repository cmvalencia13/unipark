package com.unipark.android.data.remote.api

import com.unipark.android.data.remote.dto.UserDto
import retrofit2.Response
import retrofit2.http.GET

interface UserApi {
    @GET("me")
    suspend fun getProfile(): Response<UserDto>
}
