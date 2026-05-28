package com.unipark.android.ui.driver.tabs

import android.graphics.Color as AndroidColor
import android.graphics.Typeface
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.GradientDrawable
import android.content.Context
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.VerticalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.unipark.android.domain.entities.ParkingLot
import com.unipark.android.ui.driver.DriverViewModel
import com.unipark.android.ui.driver.map.ParkingLotGeometry
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import org.osmdroid.views.overlay.Polygon

@Composable
fun MapTab(viewModel: DriverViewModel) {
    val context = LocalContext.current
    val lots by viewModel.lots.collectAsState()
    val parkingKeyLot = lots.firstOrNull()
    var showLotCard by remember { mutableStateOf(false) }

    val mapView = remember {
        Configuration.getInstance().userAgentValue = context.packageName
        MapView(context).apply {
            setTileSource(TileSourceFactory.MAPNIK)
            setMultiTouchControls(true)
            minZoomLevel = 3.0
            maxZoomLevel = 22.0
            controller.setZoom(20.0)
            controller.setCenter(ParkingLotGeometry.center)
            mapOrientation = 42f
        }
    }

    DisposableEffect(Unit) {
        onDispose { mapView.onDetach() }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { mapView },
            update = { view ->
                view.overlays.clear()

                view.overlays.add(
                    lotPolygon(
                        points = ParkingLotGeometry.parkingKeyOuter,
                        fillColor = occupancyColor(parkingKeyLot).copy(alpha = 0.45f).toAndroidArgb(),
                        strokeColor = Color(0xFF00F0FF).toAndroidArgb(),
                        strokeWidth = 6f,
                    ),
                )
                view.overlays.add(
                    lotPolygon(
                        points = ParkingLotGeometry.parkingKeyInner,
                        fillColor = occupancyColor(parkingKeyLot).copy(alpha = 0.35f).toAndroidArgb(),
                        strokeColor = Color(0xFF00F0FF).copy(alpha = 0.6f).toAndroidArgb(),
                        strokeWidth = 4f,
                    ),
                )
                view.overlays.add(
                    Marker(view).apply {
                        position = ParkingLotGeometry.center
                        setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                        icon = markerDrawable(
                            context = view.context,
                            lot = parkingKeyLot,
                            color = occupancyColor(parkingKeyLot).toAndroidArgb(),
                        )
                        setOnMarkerClickListener { _, _ ->
                            showLotCard = true
                            true
                        }
                    },
                )
                view.invalidate()
            },
        )

        AnimatedVisibility(
            visible = showLotCard && parkingKeyLot != null,
            modifier = Modifier.align(Alignment.BottomCenter),
            enter = slideInVertically { it } + fadeIn(),
            exit = slideOutVertically { it } + fadeOut(),
        ) {
            parkingKeyLot?.let {
                LotInfoCard(
                    lot = it,
                    onDismiss = { showLotCard = false },
                    modifier = Modifier
                        .padding(16.dp)
                        .padding(bottom = 80.dp),
                )
            }
        }
    }
}

private fun lotPolygon(
    points: List<GeoPoint>,
    fillColor: Int,
    strokeColor: Int,
    strokeWidth: Float,
): Polygon = Polygon().apply {
    this.points = points
    this.fillColor = fillColor
    outlinePaint.color = strokeColor
    outlinePaint.strokeWidth = strokeWidth
}

private fun markerDrawable(
    context: Context,
    lot: ParkingLot?,
    color: Int,
): android.graphics.drawable.Drawable {
    val density = context.resources.displayMetrics.density
    val container = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER
        setPadding(0, 0, 0, (4 * density).toInt())
    }
    val badgeSize = (44 * density).toInt()
    val badge = TextView(context).apply {
        text = "P"
        textSize = 20f
        typeface = Typeface.DEFAULT_BOLD
        setTextColor(AndroidColor.WHITE)
        gravity = Gravity.CENTER
        background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(color)
        }
        layoutParams = LinearLayout.LayoutParams(badgeSize, badgeSize)
    }
    val label = TextView(context).apply {
        text = "${lot?.availableSpots ?: 0} libres"
        textSize = 11f
        typeface = Typeface.DEFAULT_BOLD
        setTextColor(AndroidColor.WHITE)
        gravity = Gravity.CENTER
        setPadding((8 * density).toInt(), (3 * density).toInt(), (8 * density).toInt(), (3 * density).toInt())
        background = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 50 * density
            setColor(AndroidColor.argb(180, 0, 0, 0))
        }
    }
    container.addView(badge)
    container.addView(label)
    val widthSpec = android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED)
    val heightSpec = android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED)
    container.measure(widthSpec, heightSpec)
    container.layout(0, 0, container.measuredWidth, container.measuredHeight)
    val bitmap = Bitmap.createBitmap(container.measuredWidth, container.measuredHeight, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    container.draw(canvas)
    return BitmapDrawable(context.resources, bitmap)
}

fun occupancyColor(lot: ParkingLot?): Color {
    val pct = lot?.occupancyPercentage ?: 0.0
    return when {
        pct < 0.7 -> Color(0xFF36FFC4)
        pct < 0.9 -> Color(0xFFFF9800)
        else -> Color(0xFFFFB4AB)
    }
}

@Composable
fun LotInfoCard(lot: ParkingLot, onDismiss: () -> Unit, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xCC1E2024)),
        border = BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
    ) {
        Column(
            modifier = Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        "PARQUEO KEY",
                        fontSize = 11.sp,
                        color = Color(0xFF00F0FF),
                        letterSpacing = 1.2.sp,
                        fontWeight = FontWeight.SemiBold,
                    )
                    Text(
                        "Campus Universidad",
                        fontSize = 18.sp,
                        color = Color(0xFFE2E2E8),
                        fontWeight = FontWeight.Bold,
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = null, tint = Color(0xFFB9CACB))
                }
            }

            Row(modifier = Modifier.fillMaxWidth()) {
                StatItem(
                    value = "${lot.availableSpots}",
                    label = "Libres",
                    color = if (lot.isFull) Color(0xFFFFB4AB) else Color(0xFF36FFC4),
                    modifier = Modifier.weight(1f),
                )
                VerticalDivider(color = Color(0xFF3B494B), modifier = Modifier.height(36.dp))
                StatItem("${lot.capacityUsed}", "Ocupados", Color(0xFFE2E2E8), Modifier.weight(1f))
                VerticalDivider(color = Color(0xFF3B494B), modifier = Modifier.height(36.dp))
                StatItem("${lot.capacityTotal}", "Total", Color(0xFFE2E2E8), Modifier.weight(1f))
            }

            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Row {
                    Text(
                        "Ocupacion",
                        fontSize = 12.sp,
                        color = Color(0xFFB9CACB),
                        modifier = Modifier.weight(1f),
                    )
                    Text(
                        "${(lot.occupancyPercentage * 100).toInt()}%",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = occupancyColor(lot),
                    )
                }
                LinearProgressIndicator(
                    progress = { lot.occupancyPercentage.toFloat() },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp)
                        .clip(RoundedCornerShape(4.dp)),
                    color = occupancyColor(lot),
                    trackColor = Color(0xFF333539),
                )
            }

            if (lot.isFull) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        Icons.Default.Warning,
                        contentDescription = null,
                        tint = Color(0xFFFFB4AB),
                        modifier = Modifier.size(18.dp),
                    )
                    Text(
                        "Parqueo lleno - busca otro acceso",
                        color = Color(0xFFFFB4AB),
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 14.sp,
                    )
                }
            }
        }
    }
}

@Composable
fun StatItem(value: String, label: String, color: Color, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(3.dp),
    ) {
        Text(value, color = color, fontSize = 22.sp, fontWeight = FontWeight.Bold)
        Text(label, color = Color(0xFFB9CACB), fontSize = 12.sp)
    }
}

private fun Color.toAndroidArgb(): Int = AndroidColor.argb(
    (alpha * 255).toInt(),
    (red * 255).toInt(),
    (green * 255).toInt(),
    (blue * 255).toInt(),
)
