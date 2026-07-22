package com.devsoc.freerooms.navigation

import androidx.navigation.NavHostController
import com.devsoc.freerooms.core.ui.FreeroomsPage

internal class FreeroomsNavigationActions(
    private val navController: NavHostController,
) {
    fun navigateTo(page: FreeroomsPage) {
        when (page) {
            FreeroomsPage.Building -> navigateToTab(FreeroomsRoute.Buildings)
            FreeroomsPage.Rooms -> navigateToTab(FreeroomsRoute.Rooms)
            FreeroomsPage.Map -> navigateToMap()
        }
    }

    fun navigateToBuildingRooms(buildingId: String) {
        navController.navigate(FreeroomsRoute.buildingRooms(buildingId))
    }

    fun navigateToRoomDetails(roomId: String) {
        navController.navigate(FreeroomsRoute.roomDetails(roomId))
    }

    fun navigateBack() {
        navController.popBackStack()
    }

    private fun navigateToTab(route: String) {
        navController.navigate(route) {
            popUpTo(FreeroomsRoute.Buildings) {
                saveState = true
            }
            launchSingleTop = true
            restoreState = true
        }
    }

    private fun navigateToMap() {
        if (navController.currentDestination?.route == FreeroomsRoute.Map) {
            return
        }

        navController.navigate(FreeroomsRoute.Map) {
            launchSingleTop = true
        }
    }
}
