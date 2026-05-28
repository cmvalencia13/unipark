package com.unipark.android.ui.driver

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.outlined.Badge
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Map
import androidx.compose.material.icons.outlined.QrCode
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.unipark.android.ui.driver.tabs.AccessQRTab
import com.unipark.android.ui.driver.tabs.HomeTab
import com.unipark.android.ui.driver.tabs.MapTab
import com.unipark.android.ui.driver.tabs.PermitSticker
import com.unipark.android.ui.theme.UniParkDriverTheme
import com.unipark.android.ui.theme.upBackground
import com.unipark.android.ui.theme.upPrimary
import com.unipark.android.ui.theme.upSurface
import com.unipark.android.ui.theme.upSurfaceHigh
import com.unipark.android.ui.theme.upTextSecondary
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class DriverActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            UniParkDriverTheme {
                DriverExperience(onSignOut = ::finish)
            }
        }
    }
}

private data class DriverTabItem(
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector,
)

private val driverTabs = listOf(
    DriverTabItem("Inicio", Icons.Outlined.Home, Icons.Filled.Home),
    DriverTabItem("Mapa", Icons.Outlined.Map, Icons.Filled.Map),
    DriverTabItem("Permiso", Icons.Outlined.Badge, Icons.Filled.Badge),
    DriverTabItem("Acceso", Icons.Outlined.QrCode, Icons.Filled.QrCode),
)

@Composable
fun DriverExperience(
    onSignOut: () -> Unit,
    viewModel: DriverViewModel = hiltViewModel(),
) {
    var selectedTab by remember { mutableIntStateOf(0) }

    Scaffold(
        containerColor = upBackground,
        topBar = { UniParkHeader(onSignOut = onSignOut) },
        bottomBar = {
            NavigationBar(containerColor = Color(0xFF0C0E12)) {
                driverTabs.forEachIndexed { index, item ->
                    val selected = selectedTab == index
                    NavigationBarItem(
                        selected = selected,
                        onClick = { selectedTab = index },
                        icon = {
                            Icon(
                                imageVector = if (selected) item.selectedIcon else item.icon,
                                contentDescription = item.label,
                            )
                        },
                        label = { Text(item.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = upPrimary,
                            selectedTextColor = upPrimary,
                            unselectedIconColor = upTextSecondary,
                            unselectedTextColor = upTextSecondary,
                            indicatorColor = upSurface,
                        ),
                    )
                }
            }
        },
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(upBackground)
                .padding(paddingValues),
        ) {
            when (selectedTab) {
                0 -> HomeTab(
                    viewModel = viewModel,
                    onOpenAccess = { selectedTab = 3 },
                )
                1 -> MapTab(viewModel = viewModel)
                2 -> PermitSticker(viewModel = viewModel)
                3 -> AccessQRTab(viewModel = viewModel)
            }
        }
    }
}

@Composable
fun UniParkHeader(onSignOut: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(upBackground),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.statusBars)
                .height(64.dp)
                .padding(horizontal = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(upSurface),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Default.Person, contentDescription = null, tint = upTextSecondary)
            }
            Text(
                text = "UniPark",
                color = upPrimary,
                fontWeight = FontWeight.Bold,
                fontSize = 28.sp,
            )
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                IconButton(onClick = { }) {
                    Icon(
                        Icons.Default.Notifications,
                        contentDescription = "Notificaciones",
                        tint = upPrimary,
                    )
                }
                IconButton(onClick = onSignOut) {
                    Icon(
                        Icons.Default.Logout,
                        contentDescription = "Cerrar sesion",
                        tint = upPrimary,
                    )
                }
            }
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(upSurfaceHigh),
        )
    }
}
