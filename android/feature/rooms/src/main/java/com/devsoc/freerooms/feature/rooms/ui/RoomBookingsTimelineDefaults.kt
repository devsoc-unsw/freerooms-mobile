package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp
import java.time.format.DateTimeFormatter
import java.util.Locale

internal val BookingsBoxShape = RoundedCornerShape(12.dp)
internal val BookingsDateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.US)
internal val BookingsTimeFormatter = DateTimeFormatter.ofPattern("HH:mm", Locale.US)
internal val TimelineHours = 9..23
internal val SlotHeight = 60.dp
internal val TimeColumnWidth = 52.dp
internal val ThickLine = 2.dp
internal val ThinLine = 1.dp
internal val TimelineStartHour = 9
internal val TimelineEndHour = 24
