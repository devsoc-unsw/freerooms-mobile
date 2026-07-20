package com.devsoc.freerooms.navigation

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument

@Composable
internal fun FreeroomsNavHost(
    navController: NavHostController,
    buildingContent: @Composable (Modifier) -> Unit,
    buildingRoomsContent: @Composable (buildingId: String, Modifier) -> Unit,
    roomsContent: @Composable (Modifier) -> Unit,
    mapContent: @Composable (Modifier) -> Unit,
    modifier: Modifier = Modifier,
) {
    NavHost(
        navController = navController,
        startDestination = FreeroomsRoute.Buildings,
        modifier = modifier,
    ) {
        composable(FreeroomsRoute.Buildings) {
            buildingContent(Modifier.fillMaxSize())
        }

        composable(
            route = FreeroomsRoute.BuildingRooms,
            arguments = listOf(
                navArgument("buildingId") {
                    type = NavType.StringType
                },
            ),
        ) { entry ->
            val buildingId = entry.arguments?.getString("buildingId").orEmpty()
            buildingRoomsContent(buildingId, Modifier.fillMaxSize())
        }

        composable(FreeroomsRoute.Rooms) {
            roomsContent(Modifier.fillMaxSize())
        }

        composable(FreeroomsRoute.Map) {
            mapContent(Modifier.fillMaxSize())
        }
    }
}
