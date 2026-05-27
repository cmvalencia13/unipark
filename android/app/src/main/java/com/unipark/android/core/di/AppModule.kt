package com.unipark.android.core.di

import android.content.Context
import androidx.room.Room
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import com.unipark.android.core.auth.OIDCConfig
import com.unipark.android.core.network.AuthInterceptor
import com.unipark.android.core.network.NetworkConfig
import com.unipark.android.data.local.ScanDao
import com.unipark.android.data.local.UniParkDatabase
import com.unipark.android.data.remote.LotApiService
import com.unipark.android.data.remote.PassApiService
import com.unipark.android.data.remote.ScanApiService
import com.unipark.android.data.remote.ViolationApiService
import com.unipark.android.data.repositories.AuthRepositoryImpl
import com.unipark.android.data.repositories.LotRepositoryImpl
import com.unipark.android.data.repositories.PassRepositoryImpl
import com.unipark.android.data.repositories.ScanRepositoryImpl
import com.unipark.android.data.repositories.ViolationRepositoryImpl
import com.unipark.android.domain.repositories.AuthRepository
import com.unipark.android.domain.repositories.LotRepository
import com.unipark.android.domain.repositories.PassRepository
import com.unipark.android.domain.repositories.ScanRepository
import com.unipark.android.domain.repositories.ViolationRepository
import dagger.Module
import dagger.Provides
import dagger.Binds
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import okhttp3.CertificatePinner
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides
    @Singleton
    fun provideNetworkConfig(): NetworkConfig = NetworkConfig()

    @Provides
    @Singleton
    fun provideOIDCConfig(): OIDCConfig = OIDCConfig()

    @Provides
    @Singleton
    fun provideMoshi(): Moshi = Moshi.Builder()
        .add(KotlinJsonAdapterFactory())
        .build()

    @Provides
    @Singleton
    fun provideOkHttpClient(authInterceptor: AuthInterceptor): OkHttpClient {
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BASIC
        }

        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(logging)
            .certificatePinner(CertificatePinner.Builder().build())
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(
        networkConfig: NetworkConfig,
        okHttpClient: OkHttpClient,
        moshi: Moshi,
    ): Retrofit = Retrofit.Builder()
        .baseUrl(networkConfig.baseUrl)
        .client(okHttpClient)
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .build()

    @Provides
    @Singleton
    fun provideLotApiService(retrofit: Retrofit): LotApiService = retrofit.create(LotApiService::class.java)

    @Provides
    @Singleton
    fun providePassApiService(retrofit: Retrofit): PassApiService = retrofit.create(PassApiService::class.java)

    @Provides
    @Singleton
    fun provideScanApiService(retrofit: Retrofit): ScanApiService = retrofit.create(ScanApiService::class.java)

    @Provides
    @Singleton
    fun provideViolationApiService(retrofit: Retrofit): ViolationApiService = retrofit.create(ViolationApiService::class.java)

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): UniParkDatabase =
        Room.databaseBuilder(context, UniParkDatabase::class.java, "unipark.db")
            .fallbackToDestructiveMigration()
            .build()

    @Provides
    fun provideScanDao(database: UniParkDatabase): ScanDao = database.scanDao()
}

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    @Singleton
    abstract fun bindAuthRepository(impl: AuthRepositoryImpl): AuthRepository

    @Binds
    @Singleton
    abstract fun bindLotRepository(impl: LotRepositoryImpl): LotRepository

    @Binds
    @Singleton
    abstract fun bindPassRepository(impl: PassRepositoryImpl): PassRepository

    @Binds
    @Singleton
    abstract fun bindScanRepository(impl: ScanRepositoryImpl): ScanRepository

    @Binds
    @Singleton
    abstract fun bindViolationRepository(impl: ViolationRepositoryImpl): ViolationRepository
}
