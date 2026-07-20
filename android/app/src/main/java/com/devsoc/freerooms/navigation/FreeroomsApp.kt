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
    buildingContent: @Composable (Modifier, onBuildingClick: (String) -> Unit) -> Unit,
    buildingRoomsContent: @Composable (
        buildingId: String,
        Modifier,
        onBack: () -> Unit,
        onRoomClick: (String) -> Unit,
    ) -> Unit,
    roomsContent: @Composable (Modifier, onRoomClick: (String) -> Unit) -> Unit,
    roomDetailsContent: @Composable (
        roomId: String,
        Modifier,
        onBack: () -> Unit,
    ) -> Unit,
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
    val currentRoute = navBackStackEntry?.destination?.route
    val selectedPage = currentRoute.toFreeroomsPage()
    val showBottomBar = !currentRoute.hidesBottomBar()
    val isRoomDetails = currentRoute.isRoomDetailsRoute()

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Gray)
            .then(
                if (isRoomDetails) {
                    Modifier
                } else {
                    Modifier.statusBarsPadding()
                },
            )
            .then(
                if (showBottomBar) {
                    Modifier
                } else {
                    Modifier.navigationBarsPadding()
                },
            ),
    ) {
        FreeroomsNavHost(
            navController = navController,
            buildingContent = { contentModifier ->
                buildingContent(contentModifier, navigationActions::navigateToBuildingRooms)
            },
            buildingRoomsContent = { buildingId, contentModifier ->
                buildingRoomsContent(
                    buildingId,
                    contentModifier,
                    navigationActions::navigateBack,
                    navigationActions::navigateToRoomDetails,
                )
            },
            roomsContent = { contentModifier ->
                roomsContent(contentModifier, navigationActions::navigateToRoomDetails)
            },
            roomDetailsContent = { roomId, contentModifier ->
                roomDetailsContent(
                    roomId,
                    contentModifier,
                    navigationActions::navigateBack,
                )
            },
            mapContent = mapContent,
            modifier = Modifier.weight(1f),
        )

        if (showBottomBar) {
            FreeroomsBottomNavBar(
                selectedPage = selectedPage,
                onPageSelected = navigationActions::navigateTo,
                modifier = Modifier.navigationBarsPadding(),
            )
        }
    }
}
