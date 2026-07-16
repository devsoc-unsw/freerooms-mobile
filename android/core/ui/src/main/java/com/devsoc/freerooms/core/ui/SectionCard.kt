package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.unit.dp

@Composable
fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = title,
        modifier = modifier.fillMaxWidth(),
        style = MaterialTheme.typography.titleMedium,
        color = Brown,
    )
}

@Composable
fun SectionCardItem(
    isFirst: Boolean,
    isLast: Boolean,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit,
) {
    val shape = RoundedCornerShape(
        topStart = if (isFirst) 36.dp else 0.dp,
        topEnd = if (isFirst) 36.dp else 0.dp,
        bottomStart = if (isLast) 36.dp else 0.dp,
        bottomEnd = if (isLast) 36.dp else 0.dp,
    )

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(Color.White)
            .drawWithContent {
                drawContent()

                val strokeWidth = 1.dp.toPx()
                val edge = strokeWidth / 2
                val radius = 36.dp.toPx()
                val arcRadius = radius - edge
                val arcControl = arcRadius * 0.5522848f
                val right = size.width - edge
                val bottom = size.height - edge
                val border = Path()

                when {
                    isFirst && isLast -> {
                        drawRoundRect(
                            color = FR_Orange,
                            topLeft = Offset(edge, edge),
                            size = Size(
                                width = size.width - strokeWidth,
                                height = size.height - strokeWidth,
                            ),
                            cornerRadius = CornerRadius(arcRadius),
                            style = Stroke(strokeWidth),
                        )
                    }
                    isFirst -> {
                        border.moveTo(edge, bottom)
                        border.lineTo(edge, radius)
                        border.cubicTo(
                            edge,
                            radius - arcControl,
                            radius - arcControl,
                            edge,
                            radius,
                            edge,
                        )
                        border.lineTo(size.width - radius, edge)
                        border.cubicTo(
                            size.width - radius + arcControl,
                            edge,
                            right,
                            radius - arcControl,
                            right,
                            radius,
                        )
                        border.lineTo(right, bottom)
                        drawPath(border, FR_Orange, style = Stroke(strokeWidth))
                    }
                    isLast -> {
                        border.moveTo(edge, edge)
                        border.lineTo(edge, size.height - radius)
                        border.cubicTo(
                            edge,
                            size.height - radius + arcControl,
                            radius - arcControl,
                            bottom,
                            radius,
                            bottom,
                        )
                        border.lineTo(size.width - radius, bottom)
                        border.cubicTo(
                            size.width - radius + arcControl,
                            bottom,
                            right,
                            size.height - radius + arcControl,
                            right,
                            size.height - radius,
                        )
                        border.lineTo(right, edge)
                        drawPath(border, FR_Orange, style = Stroke(strokeWidth))
                    }
                    else -> {
                        border.moveTo(edge, edge)
                        border.lineTo(edge, bottom)
                        border.moveTo(right, edge)
                        border.lineTo(right, bottom)
                        drawPath(border, FR_Orange, style = Stroke(strokeWidth))
                    }
                }
            }
            .padding(horizontal = 16.dp),
    ) {
        content()

        if (!isLast) {
            HorizontalDivider(
                modifier = Modifier.padding(start = 60.dp),
                thickness = 1.dp,
                color = Gray,
            )
        }
    }
}
