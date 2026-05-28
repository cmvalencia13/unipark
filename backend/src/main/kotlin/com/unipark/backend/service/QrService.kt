package com.unipark.backend.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.util.Base64
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Servicio centralizado para generación y verificación de payloads QR.
 * Formato: "nonce:HMAC-SHA256(nonce, secret)" en Base64.
 */
@Service
class QrService(
    @Value("\${app.security.qr-secret:default-secret-key-change-me}")
    private val qrSecret: String
) {

    /** Genera el payload QR completo: "nonce:firma" */
    fun buildPayload(nonce: String): String {
        val signature = computeHmac(nonce)
        return "$nonce:$signature"
    }

    /** Verifica que un payload tenga firma válida. */
    fun verifyPayload(payload: String): Boolean {
        val parts = payload.split(":")
        if (parts.size != 2) return false
        return computeHmac(parts[0]) == parts[1]
    }

    /** Devuelve el nonce si la firma es válida, null si no. */
    fun extractNonce(payload: String): String? {
        val parts = payload.split(":")
        if (parts.size != 2) return null
        return if (computeHmac(parts[0]) == parts[1]) parts[0] else null
    }

    private fun computeHmac(data: String): String {
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(SecretKeySpec(qrSecret.toByteArray(), "HmacSHA256"))
        return Base64.getEncoder().encodeToString(mac.doFinal(data.toByteArray()))
    }
}
