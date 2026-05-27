package com.unipark.android.core.nfc

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import com.unipark.android.core.auth.TokenStorage
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class PassHceService : HostApduService() {
    @Inject lateinit var tokenStorage: TokenStorage

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        val payload = tokenStorage.getAccessToken()
            ?.let { "UNIPARK_PASS:$it" }
            ?: "UNIPARK_PASS:NO_ACTIVE_PASS"
        return payload.toByteArray(Charsets.UTF_8) + STATUS_SUCCESS
    }

    override fun onDeactivated(reason: Int) = Unit

    private companion object {
        val STATUS_SUCCESS = byteArrayOf(0x90.toByte(), 0x00.toByte())
    }
}
