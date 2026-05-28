package com.unipark.android.core.di

import com.unipark.android.data.repository.LotRepositoryImpl
import com.unipark.android.data.repository.PassRepositoryImpl
import com.unipark.android.data.repository.UserRepositoryImpl
import com.unipark.android.domain.repository.LotRepository
import com.unipark.android.domain.repository.PassRepository
import com.unipark.android.domain.repository.UserRepository
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindLotRepository(
        lotRepositoryImpl: LotRepositoryImpl
    ): LotRepository

    @Binds
    @Singleton
    abstract fun bindUserRepository(
        userRepositoryImpl: UserRepositoryImpl
    ): UserRepository

    @Binds
    @Singleton
    abstract fun bindPassRepository(
        passRepositoryImpl: PassRepositoryImpl
    ): PassRepository
}
