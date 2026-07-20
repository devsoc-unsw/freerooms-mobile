package com.devsoc.freerooms.feature.rooms.ui

import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.devsoc.freerooms.core.ui.Gray2

@Composable
internal fun RoomDetailsHeroImage(
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
