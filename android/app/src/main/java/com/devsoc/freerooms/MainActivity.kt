package com.devsoc.freerooms

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FreeroomsBottomNavBar
import com.devsoc.freerooms.core.ui.FreeroomsPage
import com.devsoc.freerooms.core.ui.FreeroomsTheme
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

                Box(modifier = Modifier.fillMaxSize()) {
                    when (selectedPage) {
                        FreeroomsPage.Building -> BuildingScreen(
                            viewModel = buildingViewModel,
                            modifier = Modifier.fillMaxSize(),
                        )
                        FreeroomsPage.Map -> MapScreen(
                            modifier = Modifier.fillMaxSize(),
                        )
                        FreeroomsPage.Rooms -> RoomsScreen(
                            modifier = Modifier.fillMaxSize(),
                        )
                    }

                    Text(
                        text = selectedPage.title,
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(top = 32.dp, start = 16.dp),
                        style = MaterialTheme.typography.headlineLarge,
                        fontWeight = FontWeight.Bold,
                        color = Brown,
                    )

                    FreeroomsBottomNavBar(
                        selectedPage = selectedPage,
                        onPageSelected = { page -> selectedPage = page },
                        modifier = Modifier.align(Alignment.BottomCenter),
                    )
                }
            }
        }
    }
}
