package com.devsoc.freerooms.feature.rooms.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Brown
import com.devsoc.freerooms.core.ui.FR_Orange
import com.devsoc.freerooms.core.ui.Gray3
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

private val BookingsBoxShape = RoundedCornerShape(12.dp)
private val DateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.US)
private val TimelineHours = 9..23
private val SlotHeight = 60.dp
private val TimeColumnWidth = 52.dp
private val ThickLine = 2.dp
private val ThinLine = 1.dp

@Composable
internal fun RoomBookingsTimeline(
    modifier: Modifier = Modifier,
) {
    val today = LocalDate.now().format(DateFormatter)
    val lineColor = Gray3

    Column(
        modifier = modifier
            .border(1.dp, FR_Orange, BookingsBoxShape)
            .padding(12.dp),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Room Bookings",
                modifier = Modifier.weight(1f),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                color = Brown,
            )
            Text(
                text = today,
                style = MaterialTheme.typography.bodyMedium,
                color = Brown,
            )
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 12.dp)
                .weight(1f)
                .verticalScroll(rememberScrollState()),
        ) {
            Box(modifier = Modifier.fillMaxWidth()) {
                HorizontalDivider(
                    thickness = ThickLine,
                    color = lineColor,
                )
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .padding(start = TimeColumnWidth)
                        .width(ThinLine)
                        .height(ThickLine)
                        .background(lineColor),
                )
            }

            TimelineHours.forEach { hour ->
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(SlotHeight),
                ) {
                    HorizontalDivider(
                        modifier = Modifier.align(Alignment.Center),
                        thickness = ThinLine,
                        color = lineColor,
                    )
                    HorizontalDivider(
                        modifier = Modifier.align(Alignment.BottomCenter),
                        thickness = ThickLine,
                        color = lineColor,
                    )

                    Text(
                        text = String.format(Locale.US, "%02d:00", hour),
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .width(TimeColumnWidth)
                            .padding(end = 8.dp),
                        style = MaterialTheme.typography.bodyMedium,
                        color = Brown,
                    )

                    Box(
                        modifier = Modifier
                            .align(Alignment.TopStart)
                            .padding(start = TimeColumnWidth)
                            .width(ThinLine)
                            .fillMaxHeight()
                            .background(lineColor),
                    )
                }
            }
        }
    }
}
