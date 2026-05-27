package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.util.UUID

@Parcelize
data class User(
    val id: UUID,
    val email: String,
    val fullName: String,
    val role: UserRole,
    val active: Boolean,
) : Parcelable

enum class UserRole { DRIVER, SECURITY_GUARD, ADMIN, SUPERADMIN }
