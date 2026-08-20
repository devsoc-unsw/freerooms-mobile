package com.devsoc.freerooms.feature.map.ui

import android.util.Log
import com.devsoc.freerooms.feature.buildings.data.*

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.material3.MaterialTheme
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.maps.android.compose.rememberUpdatedMarkerState
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.DarkGray2
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.map.data.MapViewModel
import com.google.maps.android.compose.MapUiSettings

@Composable
fun MapScreen(
    viewModel: MapViewModel,
    modifier: Modifier = Modifier,
    onBuildingClick: (Building) -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val buildings = (uiState as? ResponseState.Success<List<Building>>)?.data.orEmpty()
    val uiSettings by remember {
        mutableStateOf(
            MapUiSettings(
                zoomControlsEnabled = false,
                compassEnabled = false,
                myLocationButtonEnabled = true
            )
        )
    }

    val unswKensington = LatLng(-33.9173, 151.2313)
    
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(unswKensington, 16.0f)
    }

    val unswBounds = LatLngBounds(
        LatLng(-33.9215, 151.2260),
        LatLng(-33.9135, 151.2370)
    )

    val mapProperties = remember {
        MapProperties(
            latLngBoundsForCameraTarget = unswBounds,
            minZoomPreference = 15.0f,
            maxZoomPreference = 20.0f
        )
    }

    // Using currentZoom state to force recomposition when zoom changes
    var currentZoom by remember { mutableFloatStateOf(cameraPositionState.position.zoom) }

    LaunchedEffect(cameraPositionState.isMoving) {
        snapshotFlow { cameraPositionState.position.zoom }
            .collect { zoom ->
                currentZoom = zoom
            }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        GoogleMap(
            modifier = Modifier.fillMaxSize(),
            cameraPositionState = cameraPositionState,
            properties = mapProperties,
            uiSettings = uiSettings
        ) {
            val showBuildingName = currentZoom >= 17.5f
            buildings.forEach { building ->
                MapBuildingMarker(
                    building = building,
                    markerState = rememberUpdatedMarkerState(position = LatLng(building.lat, building.long)),
                    onBuildingClick = onBuildingClick,
                    showBuildingName = showBuildingName
                )
            }
        }

    }
}
