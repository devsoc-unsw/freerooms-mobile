package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.BottomSheetDefaults
import androidx.compose.material3.BottomSheetScaffold
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.SheetValue
import androidx.compose.material3.rememberBottomSheetScaffoldState
import androidx.compose.material3.rememberStandardBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.freeroomsClickable

private val SheetShape = RoundedCornerShape(topStart = 30.dp, topEnd = 30.dp)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoomDetailsScreen(
    roomName: String,
    @DrawableRes roomImageResId: Int?,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val configuration = LocalConfiguration.current
    val sheetPeekHeight = (configuration.screenHeightDp * 0.65f).dp
    val scaffoldState = rememberBottomSheetScaffoldState(
        bottomSheetState = rememberStandardBottomSheetState(
            initialValue = SheetValue.PartiallyExpanded,
            skipHiddenState = true,
        ),
    )

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
            sheetDragHandle = { BottomSheetDefaults.DragHandle() },
            sheetContent = {
                RoomDetailsSheetChrome()
            },
            containerColor = Gray,
            modifier = Modifier.fillMaxSize(),
        ) {
            RoomDetailsHeroImage(
                roomName = roomName,
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
    }
}

@Composable
private fun RoomDetailsHeroImage(
    roomName: String,
    @DrawableRes roomImageResId: Int?,
    modifier: Modifier = Modifier,
) {
    val imageModifier = modifier
        .fillMaxWidth()
        .aspectRatio(4f / 3f)

    if (roomImageResId != null) {
        Image(
            painter = painterResource(roomImageResId),
            contentDescription = roomName,
            modifier = imageModifier,
            contentScale = ContentScale.Crop,
        )
    } else {
        Box(
            modifier = imageModifier.background(Gray2),
        )
    }
}

@Composable
private fun RoomDetailsSheetChrome(
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .fillMaxHeight(),
    ) {
        // Empty chrome for now — header + bookings land in later steps.
        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Composable
private fun RoomDetailsBackButton(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .size(40.dp)
            .clip(CircleShape)
            .background(Color.White)
            .freeroomsClickable(onClick = onBack),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
            contentDescription = "Back",
            modifier = Modifier.size(22.dp),
            tint = FR_Orange,
        )
    }
}
