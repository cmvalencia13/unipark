package com.unipark.android.ui.driver.tabs

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.unipark.android.presentation.driver.generateQRBitmap
import com.unipark.android.ui.driver.DriverViewModel
import com.unipark.android.ui.theme.GlassCard
import com.unipark.android.ui.theme.upBackground
import com.unipark.android.ui.theme.upPrimary
import com.unipark.android.ui.theme.upSecondary
import com.unipark.android.ui.theme.upTextPrimary
import com.unipark.android.ui.theme.upTextSecondary

@Composable
fun PermitSticker(viewModel: DriverViewModel) {
    val stickerPermit by viewModel.stickerPermit.collectAsState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(upBackground)
            .padding(16.dp),
        contentAlignment = Alignment.Center,
    ) {
        if (stickerPermit == null) {
            EmptyStickerState(
                onScanSticker = {
                    viewModel.saveStickerPermit("unipark-sticker:roberto:2025-2026")
                },
            )
        } else {
            SavedStickerState(
                qrContent = stickerPermit!!.qrContent,
                onUpdate = {
                    viewModel.saveStickerPermit("unipark-sticker:updated:${System.currentTimeMillis()}")
                },
            )
        }
    }
}

@Composable
private fun EmptyStickerState(onScanSticker: () -> Unit) {
    GlassCard {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            androidx.compose.material3.Icon(
                Icons.Default.QrCodeScanner,
                contentDescription = null,
                tint = upPrimary,
                modifier = Modifier.size(64.dp),
            )
            Text("Permiso Fisico Digital", color = upTextPrimary, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Text(
                "Escanea tu pegatina universitaria una sola vez para tenerla siempre disponible digitalmente.",
                color = upTextSecondary,
                textAlign = TextAlign.Center,
            )
            Button(
                onClick = onScanSticker,
                colors = ButtonDefaults.buttonColors(containerColor = upSecondary, contentColor = upBackground),
                shape = RoundedCornerShape(16.dp),
            ) {
                Text("Escanear Pegatina", fontWeight = FontWeight.Bold)
            }
            Text(
                "Solo necesitas escanearlo una vez. Se guardara en tu perfil.",
                color = upTextSecondary,
                fontSize = 12.sp,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun SavedStickerState(
    qrContent: String,
    onUpdate: () -> Unit,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("PERMISO UNIVERSITARIO", color = upPrimary, fontSize = 11.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.1.sp)
        Column(
            modifier = Modifier
                .background(Color.White, RoundedCornerShape(20.dp))
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .background(Color(0xFFE8F7FA), RoundedCornerShape(14.dp)),
                contentAlignment = Alignment.Center,
            ) {
                Text("UP", color = Color(0xFF007E8A), fontWeight = FontWeight.Bold)
            }
            val qrBitmap = remember(qrContent) {
                generateQRBitmap(qrContent, 280).asImageBitmap()
            }
            Image(bitmap = qrBitmap, contentDescription = "QR permiso universitario", modifier = Modifier.size(280.dp))
            Text("Roberto Valencia", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 18.sp)
            Text("VALIDO 2025-2026", color = Color.DarkGray, fontSize = 12.sp)
        }
        Text(
            "Permiso Activo",
            modifier = Modifier
                .background(upSecondary.copy(alpha = 0.18f), RoundedCornerShape(999.dp))
                .padding(horizontal = 14.dp, vertical = 8.dp),
            color = upSecondary,
            fontWeight = FontWeight.Bold,
        )
        OutlinedButton(onClick = onUpdate, shape = RoundedCornerShape(16.dp)) {
            Text("Actualizar pegatina", color = upTextSecondary)
        }
    }
}
