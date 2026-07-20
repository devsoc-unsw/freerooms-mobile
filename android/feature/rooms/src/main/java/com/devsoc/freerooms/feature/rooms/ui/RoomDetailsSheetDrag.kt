package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.SheetState

@OptIn(ExperimentalMaterial3Api::class)
@Suppress("INVISIBLE_MEMBER", "INVISIBLE_REFERENCE")
internal fun SheetState.dispatchDragDelta(delta: Float) {
    anchoredDraggableState.dispatchRawDelta(delta)
}

@OptIn(ExperimentalMaterial3Api::class)
@Suppress("INVISIBLE_MEMBER", "INVISIBLE_REFERENCE")
internal suspend fun SheetState.settleAfterDrag(velocity: Float) {
    settle(velocity)
}
