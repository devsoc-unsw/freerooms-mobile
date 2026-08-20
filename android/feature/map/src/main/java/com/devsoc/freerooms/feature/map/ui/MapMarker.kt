package com.devsoc.freerooms.feature.map.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.dropShadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.shadow.Shadow
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.devsoc.freerooms.core.ui.DarkGray2
import com.devsoc.freerooms.feature.buildings.data.Building
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMapComposable
import com.google.maps.android.compose.MarkerComposable
import com.google.maps.android.compose.MarkerState
import com.google.maps.android.compose.rememberUpdatedMarkerState

@Composable
@GoogleMapComposable
fun MapBuildingMarker (
    building: Building,
    markerState: MarkerState,
    onBuildingClick: (Building) -> Unit,
    showBuildingName: Boolean
) {
    MarkerComposable(
        keys = arrayOf(showBuildingName),
        state = markerState,
        title = building.name,
        anchor = Offset(0.5f, 0.8f),
        onClick = {
            onBuildingClick(building)
            true
        }
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            if (showBuildingName) {
                Box {
                    Text(
                        text = building.name,
                        color = Color.White,
                        style = TextStyle(
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            drawStyle = Stroke(width = 10f, join = StrokeJoin.Round)
                        )
                    )
                    Text(
                        text = building.name,
                        color = Color.Black,
                        style = TextStyle(
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }
            }
            Box(
                modifier = Modifier
                    .padding(5.dp)
                    .size(16.dp)
                    .dropShadow(
                        shape = CircleShape,
                        shadow = Shadow(
                            radius = 1.dp,
                            spread = 0.5.dp,
                            color = DarkGray2,
                            offset = DpOffset(1.dp, 2.dp)
                        )
                    )
                    .background(color = capacityColour(building.numberOfAvailableRooms), shape = CircleShape)
                    .border(width = 2.dp, color = Color.White, shape = CircleShape)
            )
        }

    }
}