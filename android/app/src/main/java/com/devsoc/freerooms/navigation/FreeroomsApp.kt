package com.devsoc.freerooms.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.devsoc.freerooms.core.ui.FreeroomsBottomNavBar
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.NoWifiScreen

@Composable
internal fun FreeroomsApp(
    hasNetworkConnection: Boolean,
    buildingContent: @Composable (Modifier) -> Unit,
    roomsContent: @Composable (Modifier) -> Unit,
    mapContent: @Composable (Modifier) -> Unit,
    modifier: Modifier = Modifier,
) {
    val navController = rememberNavController()
    val navigationActions = remember(navController) {
        FreeroomsNavigationActions(navController)
    }

    if (!hasNetworkConnection) {
        NoWifiScreen(
            modifier = modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding(),
        )
        return
    }

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val selectedPage = navBackStackEntry?.destination?.route.toFreeroomsPage()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Gray)
            .statusBarsPadding(),
    ) {
        FreeroomsNavHost(
            navController = navController,
            buildingContent = buildingContent,
            roomsContent = roomsContent,
            mapContent = mapContent,
            modifier = Modifier.weight(1f),
        )

        FreeroomsBottomNavBar(
            selectedPage = selectedPage,
            onPageSelected = navigationActions::navigateTo,
            modifier = Modifier.navigationBarsPadding(),
        )
    }
}
