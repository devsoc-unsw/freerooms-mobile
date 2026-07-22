package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

private val SectionCornerRadius = 36.dp

fun <T> LazyListScope.sectionCardItems(
    items: List<T>,
    key: ((item: T) -> Any)? = null,
    itemContent: @Composable (item: T) -> Unit,
) {
    itemsIndexed(
        items = items,
        key = if (key != null) {
            { _, item -> key(item) }
        } else {
            null
        },
        contentType = { _, _ -> "section-card-item" },
    ) { index, item ->
        val isFirst = index == 0
        val isLast = index == items.lastIndex
        val colors = MaterialTheme.colorScheme
        val shape = sectionCardItemShape(isFirst = isFirst, isLast = isLast)

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(colors.surface, shape)
                .sectionCardBorders(
                    isFirst = isFirst,
                    isLast = isLast,
                    color = colors.primary,
                ),
        ) {
            SectionCardItem(
                showDivider = !isLast,
                isFirst = isFirst,
                isLast = isLast,
            ) {
                itemContent(item)
            }
        }
    }
}

fun <T> LazyListScope.freeroomsGridItems(
    items: List<T>,
    key: ((item: T) -> Any)? = null,
    horizontalSpacing: Dp = 12.dp,
    verticalSpacing: Dp = 12.dp,
    itemContent: @Composable (item: T) -> Unit,
) {
    val rows = items.chunked(2)
    itemsIndexed(
        items = rows,
        key = if (key != null) {
            { _, row -> key(row.first()) }
        } else {
            null
        },
        contentType = { _, _ -> "grid-row" },
    ) { index, rowItems ->
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = if (index != rows.lastIndex) verticalSpacing else 0.dp),
            horizontalArrangement = Arrangement.spacedBy(horizontalSpacing),
        ) {
            rowItems.forEach { item ->
                Box(modifier = Modifier.weight(1f)) {
                    itemContent(item)
                }
            }
            if (rowItems.size == 1) {
                Spacer(modifier = Modifier.weight(1f))
            }
        }
    }
}

private fun sectionCardItemShape(isFirst: Boolean, isLast: Boolean): Shape {
    return when {
        isFirst && isLast -> SectionShape
        isFirst -> RoundedCornerShape(topStart = SectionCornerRadius, topEnd = SectionCornerRadius)
        isLast -> RoundedCornerShape(
            bottomStart = SectionCornerRadius,
            bottomEnd = SectionCornerRadius,
        )
        else -> RectangleShape
    }
}

private fun Modifier.sectionCardBorders(
    isFirst: Boolean,
    isLast: Boolean,
    color: Color,
    width: Dp = 1.dp,
): Modifier {
    if (isFirst && isLast) {
        return border(width, color, SectionShape)
    }

    return drawWithContent {
        drawContent()

        val strokeWidth = width.toPx()
        val inset = strokeWidth / 2f
        val radius = SectionCornerRadius.toPx()
        val stroke = Stroke(width = strokeWidth)

        when {
            isFirst -> {
                val path = Path().apply {
                    moveTo(inset, size.height)
                    lineTo(inset, radius)
                    arcTo(
                        rect = Rect(inset, inset, inset + radius * 2, inset + radius * 2),
                        startAngleDegrees = 180f,
                        sweepAngleDegrees = 90f,
                        forceMoveTo = false,
                    )
                    lineTo(size.width - radius - inset, inset)
                    arcTo(
                        rect = Rect(
                            size.width - inset - radius * 2,
                            inset,
                            size.width - inset,
                            inset + radius * 2,
                        ),
                        startAngleDegrees = 270f,
                        sweepAngleDegrees = 90f,
                        forceMoveTo = false,
                    )
                    lineTo(size.width - inset, size.height)
                }
                drawPath(path = path, color = color, style = stroke)
            }
            isLast -> {
                val path = Path().apply {
                    moveTo(inset, 0f)
                    lineTo(inset, size.height - radius)
                    arcTo(
                        rect = Rect(
                            inset,
                            size.height - inset - radius * 2,
                            inset + radius * 2,
                            size.height - inset,
                        ),
                        startAngleDegrees = 180f,
                        sweepAngleDegrees = -90f,
                        forceMoveTo = false,
                    )
                    lineTo(size.width - radius - inset, size.height - inset)
                    arcTo(
                        rect = Rect(
                            size.width - inset - radius * 2,
                            size.height - inset - radius * 2,
                            size.width - inset,
                            size.height - inset,
                        ),
                        startAngleDegrees = 90f,
                        sweepAngleDegrees = -90f,
                        forceMoveTo = false,
                    )
                    lineTo(size.width - inset, 0f)
                }
                drawPath(path = path, color = color, style = stroke)
            }
            else -> {
                drawLine(color, Offset(inset, 0f), Offset(inset, size.height), strokeWidth)
                drawLine(
                    color,
                    Offset(size.width - inset, 0f),
                    Offset(size.width - inset, size.height),
                    strokeWidth,
                )
            }
        }
    }
}
