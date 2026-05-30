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
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.devsoc.freerooms.core.ui.FreeroomsBottomNavBar
import com.devsoc.freerooms.core.ui.FreeroomsPage
import com.devsoc.freerooms.core.ui.FreeroomsTheme
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.NoWifiScreen
import com.devsoc.freerooms.feature.buildings.ui.BuildingScreen
import com.devsoc.freerooms.feature.buildings.ui.MapScreen
import com.devsoc.freerooms.feature.rooms.ui.RoomsScreen
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.distinctUntilChanged

class MainActivity : ComponentActivity() {

    private val buildingViewModel by viewModels<com.devsoc.freerooms.feature.buildings.data.BuildingViewModel> {
        MainApplication.BuildingViewModelFactory
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
        enableEdgeToEdge()
        setContent {
            FreeroomsTheme {
                val hasNetworkConnection by rememberNetworkConnectionState()
                var selectedPage by rememberSaveable {
                    mutableStateOf(FreeroomsPage.Building)
                }

                if (hasNetworkConnection) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Gray)
                            .statusBarsPadding(),
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
                            modifier = Modifier.navigationBarsPadding(),
                        )
                    }
                } else {
                    NoWifiScreen(
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding()
                            .navigationBarsPadding(),
                    )
                }
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
