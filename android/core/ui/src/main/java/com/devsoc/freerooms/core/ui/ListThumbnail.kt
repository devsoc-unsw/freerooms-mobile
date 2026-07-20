package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp

val ListThumbnailWidth = 64.dp
val ListThumbnailSpacing = 12.dp
val SectionContentHorizontalPadding = 20.dp
val ListRowDividerInset =
    SectionContentHorizontalPadding + ListThumbnailWidth + ListThumbnailSpacing

fun Modifier.listThumbnail(): Modifier =
    this
        .width(ListThumbnailWidth)
        .aspectRatio(4f / 3f)
        .clip(RoundedCornerShape(12.dp))
