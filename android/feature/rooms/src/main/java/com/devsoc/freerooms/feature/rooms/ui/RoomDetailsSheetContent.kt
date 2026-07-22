package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.SheetState
import androidx.compose.material3.SheetValue
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.input.pointer.util.VelocityTracker
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Gray3
import com.devsoc.freerooms.core.ui.freeroomsClickable
import com.devsoc.freerooms.feature.rooms.data.Room
import com.devsoc.freerooms.feature.rooms.data.RoomBooking
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
internal fun RoomDetailsSheetContent(
    room: Room?,
    bookings: List<RoomBooking>,
    sheetState: SheetState,
    modifier: Modifier = Modifier,
) {
    val scope = rememberCoroutineScope()

    Column(
        modifier = modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .padding(horizontal = 16.dp)
            .padding(bottom = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .pointerInput(sheetState) {
                    val velocityTracker = VelocityTracker()
                    detectVerticalDragGestures(
                        onDragEnd = {
                            val velocity = velocityTracker.calculateVelocity().y
                            velocityTracker.resetTracking()
                            scope.launch {
                                sheetState.settleAfterDrag(velocity)
                            }
                        },
                        onDragCancel = {
                            velocityTracker.resetTracking()
                            scope.launch {
                                sheetState.settleAfterDrag(0f)
                            }
                        },
                        onVerticalDrag = { change, dragAmount ->
                            velocityTracker.addPosition(
                                change.uptimeMillis,
                                change.position,
                            )
                            change.consume()
                            sheetState.dispatchDragDelta(dragAmount)
                        },
                    )
                },
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            RoomDetailsDragHandle(
                onClick = {
                    scope.launch {
                        if (sheetState.currentValue == SheetValue.Expanded) {
                            sheetState.partialExpand()
                        } else {
                            sheetState.expand()
                        }
                    }
                },
            )

            RoomDetailsSheetHeader(
                room = room,
                modifier = Modifier.padding(top = 16.dp),
            )
        }

        RoomBookingsTimeline(
            bookings = bookings,
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
        )
    }
}

@Composable
private fun RoomDetailsDragHandle(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .padding(top = 6.dp, bottom = 2.dp)
            .size(width = 48.dp, height = 28.dp)
            .freeroomsClickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .width(32.dp)
                .height(4.dp)
                .clip(RoundedCornerShape(50))
                .background(Gray3),
        )
    }
}
