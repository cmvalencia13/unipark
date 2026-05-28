package com.unipark.android.core.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.outlined.Map
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material.icons.outlined.QrCodeScanner
import androidx.compose.material.icons.outlined.Warning
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.unipark.android.presentation.auth.AppRole
import com.unipark.android.presentation.auth.AuthGateScreen
import com.unipark.android.presentation.guard.LotCapacityScreen
import com.unipark.android.presentation.guard.ScannerScreen
import com.unipark.android.presentation.guard.ViolationFormScreen
import com.unipark.android.ui.driver.DriverExperience
import java.util.UUID

object Routes {
    const val AUTH = "auth"
    const val DASHBOARD = "dashboard"
    const val MAP = "map"
    const val PERMITS = "permits"
    const val ACCESS = "access"
    const val DIGITAL_PASS = "digital_pass"
    const val VIOLATION = "violation"
}

private val driverTabs = listOf(
    BottomNavTab(
        route = Routes.DASHBOARD,
        label = "Driver",
        icon = Icons.Outlined.Dashboard,
        filledIcon = Icons.Filled.Dashboard,
    ),
    BottomNavTab(
        route = Routes.MAP,
        label = "Lots",
        icon = Icons.Outlined.Map,
        filledIcon = Icons.Filled.Map,
    ),
    BottomNavTab(
        route = Routes.PERMITS,
        label = "Wallet",
        icon = Icons.Outlined.Payments,
        filledIcon = Icons.Filled.Payments,
    ),
)

private val guardTabs = listOf(
    BottomNavTab(
        route = Routes.MAP,
        label = "Lots",
        icon = Icons.Outlined.Map,
        filledIcon = Icons.Filled.Map,
    ),
    BottomNavTab(
        route = Routes.ACCESS,
        label = "Guard",
        icon = Icons.Outlined.QrCodeScanner,
        filledIcon = Icons.Filled.QrCodeScanner,
    ),
    BottomNavTab(
        route = Routes.VIOLATION,
        label = "Infracciones",
        icon = Icons.Outlined.Warning,
        filledIcon = Icons.Filled.Warning,
    ),
)

private fun tabsForRole(role: AppRole?): List<BottomNavTab> = when (role) {
    AppRole.DRIVER -> emptyList()
    AppRole.SECURITY_GUARD -> guardTabs
    null -> emptyList()
}

@Composable
fun PlaceholderScreen(title: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

@Composable
fun UniParkNavGraph() {
    val navController = rememberNavController()
    var currentRole by remember { mutableStateOf<AppRole?>(null) }
    val tabs = tabsForRole(currentRole)
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.hierarchy?.firstOrNull { destination ->
        tabs.any { it.route == destination.route }
    }?.route ?: tabs.firstOrNull()?.route ?: Routes.AUTH

    Scaffold(
        topBar = {
            if (currentRole != AppRole.DRIVER) {
                UniParkTopAppBar(
                    showLogout = currentRole != null,
                    onLogoutClick = {
                        currentRole = null
                        navController.navigate(Routes.AUTH) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                inclusive = true
                            }
                        }
                    },
                )
            }
        },
        bottomBar = {
            if (tabs.isNotEmpty()) {
                UniParkBottomNavBar(
                    tabs = tabs,
                    currentRoute = currentRoute,
                    onTabClick = { route ->
                        navController.navigate(route) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                )
            }
        },
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Routes.AUTH,
            modifier = Modifier.padding(innerPadding),
        ) {
            composable(Routes.AUTH) {
                AuthGateScreen(
                    onAuthenticated = { role ->
                        currentRole = role
                        val startRoute = when (role) {
                            AppRole.DRIVER -> Routes.DASHBOARD
                            AppRole.SECURITY_GUARD -> Routes.MAP
                        }
                        navController.navigate(startRoute) {
                            popUpTo(Routes.AUTH) { inclusive = true }
                        }
                    },
                )
            }
            composable(Routes.DASHBOARD) {
                DriverExperience(
                    onSignOut = {
                        currentRole = null
                        navController.navigate(Routes.AUTH) {
                            popUpTo(navController.graph.findStartDestination().id) {
                                inclusive = true
                            }
                        }
                    },
                )
            }
            composable(Routes.MAP) {
                LotCapacityScreen()
            }
            composable(Routes.PERMITS) {
                PlaceholderScreen("Permiso")
            }
            composable(Routes.ACCESS) {
                ScannerScreen()
            }
            composable(Routes.DIGITAL_PASS) {
                PlaceholderScreen("Acceso")
            }
            composable(Routes.VIOLATION) {
                ViolationFormScreen()
            }
        }
    }
}
