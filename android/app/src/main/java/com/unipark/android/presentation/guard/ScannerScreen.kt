package com.unipark.android.presentation.guard

import android.annotation.SuppressLint
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.FileDownload
import androidx.compose.material.icons.outlined.FileUpload
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import com.unipark.android.domain.entities.ScanDirection
import com.unipark.android.presentation.UniParkFull
import com.unipark.android.presentation.UniParkSuccess
import com.unipark.android.presentation.UniParkViewfinderRadius
import java.util.concurrent.Executors
import kotlin.math.roundToInt

@Composable
fun ScannerScreen(
    viewModel: ScannerViewModel = hiltViewModel(),
) {
    val state by viewModel.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Text("Scanner", style = MaterialTheme.typography.headlineSmall)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf("Lote A", "Lote B", "Lote C").forEach { lot ->
                FilterChip(
                    selected = state.selectedLotName == lot,
                    onClick = { viewModel.selectLot(lot) },
                    label = { Text(lot) },
                )
            }
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(360.dp)
                .clip(RoundedCornerShape(UniParkViewfinderRadius))
                .background(Color.Black),
        ) {
            CameraScanner(
                modifier = Modifier.matchParentSize(),
                onQrDetected = viewModel::onQRDetected,
            )
            AnimatedScanLine()
        }
        Text(
            "Apunta al QR del conductor",
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.align(Alignment.CenterHorizontally),
        )
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
            Button(
                onClick = { viewModel.setDirection(ScanDirection.ENTRY) },
                enabled = state.actionsEnabled,
                modifier = Modifier.weight(1f).height(56.dp),
                colors = ButtonDefaults.buttonColors(containerColor = UniParkSuccess),
                shape = RoundedCornerShape(16.dp),
            ) {
                Icon(Icons.Outlined.FileUpload, contentDescription = null)
                Text("Entrada", fontWeight = FontWeight.Bold)
            }
            Button(
                onClick = { viewModel.setDirection(ScanDirection.EXIT) },
                enabled = state.actionsEnabled,
                modifier = Modifier.weight(1f).height(56.dp),
                colors = ButtonDefaults.buttonColors(containerColor = UniParkFull),
                shape = RoundedCornerShape(16.dp),
            ) {
                Icon(Icons.Outlined.FileDownload, contentDescription = null)
                Text("Salida", fontWeight = FontWeight.Bold)
            }
        }
        OutlinedButton(
            onClick = viewModel::simulateScan,
            enabled = state.actionsEnabled,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(16.dp),
        ) {
            Text("Simular scan para demo")
        }
        Card(
            modifier = Modifier.fillMaxWidth(),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
            shape = RoundedCornerShape(16.dp),
        ) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Ultimo scan", style = MaterialTheme.typography.titleMedium)
                Text(state.lastResult?.let { "${it.status} - ${it.message} en ${it.lotName}" } ?: "Esperando QR")
                state.error?.let { Text(it, color = MaterialTheme.colorScheme.error) }
            }
        }
    }
}

@Composable
private fun AnimatedScanLine() {
    val transition = rememberInfiniteTransition(label = "scan-line")
    val y by transition.animateFloat(
        initialValue = 18f,
        targetValue = 330f,
        animationSpec = infiniteRepeatable(
            animation = tween(1600),
            repeatMode = RepeatMode.Restart,
        ),
        label = "scan-y",
    )
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .offset { IntOffset(0, y.roundToInt()) }
            .padding(horizontal = 28.dp)
            .height(3.dp)
            .background(Color.White, RoundedCornerShape(999.dp)),
    )
}

@OptIn(ExperimentalGetImage::class)
@SuppressLint("UnsafeOptInUsageError")
@Composable
private fun CameraScanner(
    modifier: Modifier,
    onQrDetected: (String) -> Unit,
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    val cameraExecutor = remember { Executors.newSingleThreadExecutor() }
    val barcodeScanner = remember { BarcodeScanning.getClient() }

    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            val previewView = PreviewView(ctx)
            val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
            cameraProviderFuture.addListener(
                {
                    val cameraProvider = cameraProviderFuture.get()
                    val preview = androidx.camera.core.Preview.Builder().build().also {
                        it.setSurfaceProvider(previewView.surfaceProvider)
                    }
                    val analysis = ImageAnalysis.Builder()
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build()
                        .also {
                            it.setAnalyzer(cameraExecutor) { imageProxy ->
                                val mediaImage = imageProxy.image
                                if (mediaImage == null) {
                                    imageProxy.close()
                                    return@setAnalyzer
                                }
                                val image = InputImage.fromMediaImage(
                                    mediaImage,
                                    imageProxy.imageInfo.rotationDegrees,
                                )
                                barcodeScanner.process(image)
                                    .addOnSuccessListener { barcodes ->
                                        barcodes.firstOrNull()?.rawValue?.let(onQrDetected)
                                    }
                                    .addOnCompleteListener { imageProxy.close() }
                            }
                        }

                    cameraProvider.unbindAll()
                    cameraProvider.bindToLifecycle(
                        lifecycleOwner,
                        CameraSelector.DEFAULT_BACK_CAMERA,
                        preview,
                        analysis,
                    )
                },
                ContextCompat.getMainExecutor(ctx),
            )
            previewView
        },
    )

    DisposableEffect(context) {
        onDispose {
            barcodeScanner.close()
            cameraExecutor.shutdown()
        }
    }
}
