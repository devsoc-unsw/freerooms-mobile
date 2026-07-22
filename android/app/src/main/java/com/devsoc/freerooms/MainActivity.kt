package com.devsoc.freerooms

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.devsoc.freerooms.core.ui.FreeroomsTheme
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.buildings.ui.BuildingScreen
import com.devsoc.freerooms.feature.buildings.ui.buildingFullImageResId
import com.devsoc.freerooms.feature.map.ui.MapScreen
import com.devsoc.freerooms.feature.rooms.ui.BuildingRoomsScreen
import com.devsoc.freerooms.feature.rooms.ui.RoomDetailsScreen
import com.devsoc.freerooms.feature.rooms.ui.RoomsScreen
import com.devsoc.freerooms.feature.rooms.ui.roomFullImageResId
import com.devsoc.freerooms.navigation.FreeroomsApp
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.distinctUntilChanged

class MainActivity : ComponentActivity() {

    private val buildingViewModel by viewModels<com.devsoc.freerooms.feature.buildings.data.BuildingViewModel> {
        MainApplication.BuildingViewModelFactory
    }

    private val roomViewModel by viewModels<com.devsoc.freerooms.feature.rooms.data.RoomViewModel> {
        MainApplication.RoomViewModelFactory
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
        enableEdgeToEdge()
        setContent {
            FreeroomsTheme {
                val hasNetworkConnection by rememberNetworkConnectionState()
                val buildingsState by buildingViewModel.uiState.collectAsStateWithLifecycle()
                val roomsState by roomViewModel.uiState.collectAsStateWithLifecycle()

                FreeroomsApp(
                    hasNetworkConnection = hasNetworkConnection,
                    buildingContent = { modifier, onBuildingClick ->
                        BuildingScreen(
                            viewModel = buildingViewModel,
                            modifier = modifier,
                            onBuildingClick = { building -> onBuildingClick(building.id) },
                        )
                    },
                    buildingRoomsContent = { buildingId, modifier, onBack, onRoomClick ->
                        val building = (buildingsState as? ResponseState.Success)
                            ?.data
                            ?.firstOrNull { building -> building.id == buildingId }
                        val rooms = (roomsState as? ResponseState.Success)
                            ?.data
                            ?.filter { room -> room.buildingId == buildingId }
                            ?.sortedBy { room -> room.name }
                            .orEmpty()
                        val roomsLoading = roomsState is ResponseState.Loading

                        BuildingRoomsScreen(
                            buildingName = building?.name ?: buildingId,
                            buildingImageResId = buildingFullImageResId(buildingId),
                            rooms = rooms,
                            roomsLoading = roomsLoading,
                            onBack = onBack,
                            onRoomClick = { room -> onRoomClick(room.id) },
                            modifier = modifier,
                        )
                    },
                    roomsContent = { modifier, onRoomClick ->
                        RoomsScreen(
                            viewModel = roomViewModel,
                            modifier = modifier,
                            onRoomClick = { room -> onRoomClick(room.id) },
                        )
                    },
                    roomDetailsContent = { roomId, modifier, onBack ->
                        val room = (roomsState as? ResponseState.Success)
                            ?.data
                            ?.firstOrNull { room -> room.id == roomId }
                        val bookingsState by roomViewModel
                            .bookingsFor(roomId)
                            .collectAsStateWithLifecycle()
                        val bookings = (bookingsState as? ResponseState.Success)
                            ?.data
                            .orEmpty()

                        RoomDetailsScreen(
                            room = room,
                            bookings = bookings,
                            roomImageResId = roomFullImageResId(roomId),
                            onBack = onBack,
                            modifier = modifier,
                        )
                    },
                    mapContent = { modifier ->
                        MapScreen(
                            modifier = modifier,
                        )
                    },
                    modifier = Modifier.fillMaxSize(),
                )
            }
        }
    }
}

@Composable
private fun rememberNetworkConnectionState(): State<Boolean> {
    val context = LocalContext.current
    val connectivityManager = remember(context) {
        context.getSystemService(ConnectivityManager::class.java)
    }

    return remember(connectivityManager) {
        connectivityManager.networkConnectionFlow()
    }.collectAsState(
        initial = connectivityManager.hasValidatedInternetConnection(),
    )
}

private fun ConnectivityManager.networkConnectionFlow(): Flow<Boolean> {
    return callbackFlow {
        trySend(hasValidatedInternetConnection())

        val networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                trySend(hasValidatedInternetConnection())
            }

            override fun onLost(network: Network) {
                trySend(hasValidatedInternetConnection())
            }

            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities,
            ) {
                trySend(hasValidatedInternetConnection())
            }
        }

        registerDefaultNetworkCallback(networkCallback)

        awaitClose {
            unregisterNetworkCallback(networkCallback)
        }
    }.distinctUntilChanged()
}

private fun ConnectivityManager.hasValidatedInternetConnection(): Boolean {
    val capabilities = activeNetwork?.let(::getNetworkCapabilities)

    return capabilities != null &&
        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
}
