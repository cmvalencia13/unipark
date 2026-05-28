package com.unipark.android.core.di

import com.unipark.android.data.remote.api.LotApi
import com.unipark.android.data.remote.api.PassApi
import com.unipark.android.data.remote.api.UserApi
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import retrofit2.Retrofit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi = retrofit.create(UserApi::class.java)

    @Provides
    @Singleton
    fun provideLotApi(retrofit: Retrofit): LotApi = retrofit.create(LotApi::class.java)

    @Provides
    @Singleton
    fun providePassApi(retrofit: Retrofit): PassApi = retrofit.create(PassApi::class.java)
}
