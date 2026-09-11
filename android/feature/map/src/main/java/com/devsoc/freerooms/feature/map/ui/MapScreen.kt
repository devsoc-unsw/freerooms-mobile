package com.devsoc.freerooms.feature.map.ui

import com.devsoc.freerooms.feature.buildings.data.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.map.data.MapViewModel
import com.devsoc.freerooms.feature.buildings.ui.buildingFullImageResId
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.RoomViewModel
import com.devsoc.freerooms.feature.rooms.ui.BuildingRoomsScreen
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.maps.android.compose.rememberUpdatedMarkerState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    viewModel: MapViewModel,
    roomViewModel: RoomViewModel,
    modifier: Modifier = Modifier,
    onRoomClick: (String) -> Unit = {}
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val buildings = (uiState as? ResponseState.Success<List<Building>>)?.data.orEmpty()
    
    val roomsState by roomViewModel.uiState.collectAsStateWithLifecycle()
    
    var selectedBuilding by remember { mutableStateOf<Building?>(null) }
    val sheetState = rememberModalBottomSheetState(
        skipPartiallyExpanded = false
    )
    var showBottomSheet by remember { mutableStateOf(false) }

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

    // Optimized state tracking
    val showBuildingName by remember {
        derivedStateOf { cameraPositionState.position.zoom >= 17.5f }
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
            buildings.forEach { building ->
                MapBuildingMarker(
                    building = building,
                    markerState = rememberUpdatedMarkerState(position = LatLng(building.lat, building.long)),
                    onBuildingClick = {
                        selectedBuilding = it
                        showBottomSheet = true
                    },
                    showBuildingName = showBuildingName
                )
            }
        }

        if (showBottomSheet && selectedBuilding != null) {
            val building = selectedBuilding!!
            val successRoomsState = roomsState as? ResponseState.Success<List<Room>>
            val rooms = successRoomsState?.data
                ?.filter { room -> room.buildingId == building.id }
                ?.sortedBy { room -> room.name }
                .orEmpty()
            val roomsLoading = roomsState is ResponseState.Loading

            ModalBottomSheet(
                onDismissRequest = { 
                    showBottomSheet = false 
                    selectedBuilding = null
                },
                sheetState = sheetState,
                containerColor = MaterialTheme.colorScheme.background,
                dragHandle = null
            ) {
                BuildingRoomsScreen(
                    buildingName = building.name,
                    buildingImageResId = buildingFullImageResId(building.id),
                    rooms = rooms,
                    roomsLoading = roomsLoading,
                    onBack = { 
                        showBottomSheet = false 
                        selectedBuilding = null
                    },
                    onRoomClick = { room -> onRoomClick(room.id) },
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}
