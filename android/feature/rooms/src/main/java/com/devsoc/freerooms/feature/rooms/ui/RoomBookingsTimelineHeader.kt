package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import com.devsoc.freerooms.core.ui.freeroomsClickable
import java.time.LocalDate

@Composable
internal fun RoomBookingsTimelineHeader(
    selectedDate: LocalDate,
    onDateClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val titleColor = MaterialTheme.colorScheme.onBackground
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = "Room Bookings",
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            color = titleColor,
        )
        Text(
            text = selectedDate.format(BookingsDateFormatter),
            modifier = Modifier.freeroomsClickable(onClick = onDateClick),
            style = MaterialTheme.typography.bodyMedium,
            color = titleColor,
        )
    }
}
