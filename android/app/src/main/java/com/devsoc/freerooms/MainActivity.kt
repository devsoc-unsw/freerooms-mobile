package com.devsoc.freerooms

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.devsoc.freerooms.core.ui.FreeroomsTheme
import com.devsoc.freerooms.features.buildings.ui.BuildingScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            FreeroomsTheme {
                BuildingScreen()
            }
        }
    }
}
