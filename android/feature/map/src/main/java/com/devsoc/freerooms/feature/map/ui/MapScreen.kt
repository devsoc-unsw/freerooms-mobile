package com.devsoc.freerooms.feature.map.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.material3.MaterialTheme
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.rememberCameraPositionState

@Composable
fun MapScreen(
    modifier: Modifier = Modifier,
) {
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

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        GoogleMap(
            modifier = Modifier.fillMaxSize(),
            cameraPositionState = cameraPositionState,
            properties = mapProperties,
        )
    }
}
