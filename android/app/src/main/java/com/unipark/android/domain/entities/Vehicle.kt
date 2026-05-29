package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.util.UUID

@Parcelize
data class Vehicle(
    val id: UUID,
    val ownerId: UUID,
    val plate: String,
    val make: String,
    val model: String,
    val color: String,
    val active: Boolean,
) : Parcelable
