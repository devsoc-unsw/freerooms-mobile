package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.BottomSheetScaffold
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.SheetValue
import androidx.compose.material3.rememberBottomSheetScaffoldState
import androidx.compose.material3.rememberStandardBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.feature.rooms.data.FavoriteRoomsStore
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.RoomBooking

private val SheetShape = RoundedCornerShape(topStart = 30.dp, topEnd = 30.dp)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomDetailsScreen(
    room: Room?,
    bookings: List<RoomBooking>,
    overallRating: Double?,
    @DrawableRes roomImageResId: Int?,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val favoriteStore = remember(context) { FavoriteRoomsStore(context) }
    var isFavorite by remember(room?.id) {
        mutableStateOf(room?.id?.let(favoriteStore::isFavorite) == true)
    }
    val configuration = LocalConfiguration.current
    val sheetPeekHeight = (configuration.screenHeightDp * 0.65f).dp
    val scaffoldState = rememberBottomSheetScaffoldState(
        bottomSheetState = rememberStandardBottomSheetState(
            initialValue = SheetValue.PartiallyExpanded,
            skipHiddenState = true,
        ),
    )
    val displayName = room?.name.orEmpty()

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Gray),
    ) {
        BottomSheetScaffold(
            scaffoldState = scaffoldState,
            sheetPeekHeight = sheetPeekHeight,
            sheetShape = SheetShape,
            sheetContainerColor = Color.White,
            sheetDragHandle = null,
            sheetSwipeEnabled = false,
            sheetContent = {
                RoomDetailsSheetContent(
                    room = room,
                    bookings = bookings,
                    overallRating = overallRating,
                    isFavorite = isFavorite,
                    onToggleFavorite = {
                        val roomId = room?.id ?: return@RoomDetailsSheetContent
                        isFavorite = favoriteStore.toggleFavorite(roomId)
                    },
                    sheetState = scaffoldState.bottomSheetState,
                )
            },
            containerColor = Gray,
            modifier = Modifier.fillMaxSize(),
        ) {
            RoomDetailsHeroImage(
                roomName = displayName,
                roomImageResId = roomImageResId,
            )
        }

        RoomDetailsBackButton(
            onBack = onBack,
            modifier = Modifier
                .align(Alignment.TopStart)
                .statusBarsPadding()
                .padding(start = 16.dp, top = 8.dp),
        )

        if (room != null) {
            RoomDetailsCapacityChip(
                capacity = room.capacity,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .statusBarsPadding()
                    .padding(end = 16.dp, top = 8.dp),
            )
        }
    }
}
