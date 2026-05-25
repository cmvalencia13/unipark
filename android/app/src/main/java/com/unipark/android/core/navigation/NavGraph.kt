package com.unipark.android.core.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Dashboard
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.QrCodeScanner
import androidx.compose.material.icons.outlined.Dashboard
import androidx.compose.material.icons.outlined.Map
import androidx.compose.material.icons.outlined.Payments
import androidx.compose.material.icons.outlined.QrCodeScanner
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController

/**
 * Route constants.
 */
object Routes {
    const val DASHBOARD = "dashboard"
    const val MAP = "map"
    const val PERMITS = "permits"
    const val ACCESS = "access"
}

/**
 * Tab definitions.
 */
val bottomNavTabs = listOf(
    BottomNavTab(
        route = Routes.DASHBOARD,
        label = "Status",
        icon = Icons.Outlined.Dashboard,
        filledIcon = Icons.Filled.Dashboard,
    ),
    BottomNavTab(
        route = Routes.MAP,
        label = "Map",
        icon = Icons.Outlined.Map,
        filledIcon = Icons.Filled.Map,
    ),
    BottomNavTab(
        route = Routes.PERMITS,
        label = "Permits",
        icon = Icons.Outlined.Payments,
        filledIcon = Icons.Filled.Payments,
    ),
    BottomNavTab(
        route = Routes.ACCESS,
        label = "Access",
        icon = Icons.Outlined.QrCodeScanner,
        filledIcon = Icons.Filled.QrCodeScanner,
    ),
)

/**
 * Placeholder screen composable.
 */
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

/**
 * Main navigation scaffold with TopAppBar + BottomNavBar + NavHost.
 */
@Composable
fun UniParkNavGraph() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.hierarchy?.firstOrNull { dest ->
        bottomNavTabs.any { it.route == dest.route }
    }?.route ?: Routes.DASHBOARD

    Scaffold(
        topBar = { UniParkTopAppBar() },
        bottomBar = {
            UniParkBottomNavBar(
                tabs = bottomNavTabs,
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
        },
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Routes.DASHBOARD,
            modifier = Modifier.padding(innerPadding),
        ) {
            composable(Routes.DASHBOARD) {
                PlaceholderScreen("Dashboard")
            }
            composable(Routes.MAP) {
                PlaceholderScreen("Availability Map")
            }
            composable(Routes.PERMITS) {
                PlaceholderScreen("Permits")
            }
            composable(Routes.ACCESS) {
                PlaceholderScreen("Access Gate")
            }
        }
    }
}
