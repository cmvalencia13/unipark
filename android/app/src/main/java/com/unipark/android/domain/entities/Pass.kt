package com.unipark.android.domain.entities

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.time.Instant
import java.util.UUID

@Parcelize
data class Pass(
    val id: UUID,
    // Cadena QR canónica del backend: "nonce:base64(HMAC-SHA256)". Se muestra tal cual.
    val qrPayload: String,
    val expiresAt: Instant,
) : Parcelable {
    val isExpired: Boolean get() = Instant.now().isAfter(expiresAt)
}
