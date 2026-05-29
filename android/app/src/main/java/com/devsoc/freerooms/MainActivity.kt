package com.devsoc.freerooms

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.devsoc.freerooms.core.ui.FreeroomsBottomNavBar
import com.devsoc.freerooms.core.ui.FreeroomsPage
import com.devsoc.freerooms.core.ui.FreeroomsTheme
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.feature.buildings.ui.BuildingScreen
import com.devsoc.freerooms.feature.buildings.ui.MapScreen
import com.devsoc.freerooms.feature.rooms.ui.RoomsScreen

class MainActivity : ComponentActivity() {

    private val buildingViewModel by viewModels<com.devsoc.freerooms.feature.buildings.data.BuildingViewModel> {
        MainApplication.BuildingViewModelFactory
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            FreeroomsTheme {
                var selectedPage by rememberSaveable {
                    mutableStateOf(FreeroomsPage.Building)
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Gray)
                        .safeDrawingPadding(),
                ) {
                    when (selectedPage) {
                        FreeroomsPage.Building -> BuildingScreen(
                            viewModel = buildingViewModel,
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f),
                        )
                        FreeroomsPage.Map -> MapScreen(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f),
                        )
                        FreeroomsPage.Rooms -> RoomsScreen(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f),
                        )
                    }

                    FreeroomsBottomNavBar(
                        selectedPage = selectedPage,
                        onPageSelected = { page -> selectedPage = page },
                    )
                }
            }
        }
    }
}
