package com.unipark.android.core.di

import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    // Providers will be added in Phase 6 (real data layer).
    // Phase 1-5 use fake in-memory data.
}
