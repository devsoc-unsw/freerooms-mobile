package com.devsoc.freerooms.navigation

import androidx.navigation.NavHostController
import com.devsoc.freerooms.core.ui.FreeroomsPage

internal class FreeroomsNavigationActions(
    private val navController: NavHostController,
) {
    fun navigateTo(page: FreeroomsPage) {
        when (page) {
            FreeroomsPage.Building -> navigateToBuildings()
            FreeroomsPage.Rooms -> navigateToRooms()
            FreeroomsPage.Map -> navigateToMap()
        }
    }

    fun navigateToBuildingRooms(buildingId: String) {
        navController.navigate(FreeroomsRoute.buildingRooms(buildingId))
    }

    fun navigateBack() {
        navController.popBackStack()
    }

    private fun navigateToBuildings() {
        navController.navigate(FreeroomsRoute.Buildings) {
            popUpTo(FreeroomsRoute.Buildings) {
                inclusive = false
            }
            launchSingleTop = true
        }
    }

    private fun navigateToRooms() {
        navController.navigate(FreeroomsRoute.Rooms) {
            popUpTo(FreeroomsRoute.Buildings)
            launchSingleTop = true
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
