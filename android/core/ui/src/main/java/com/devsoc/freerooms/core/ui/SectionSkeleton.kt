package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun SectionCardSkeleton(
    rowCount: Int,
    modifier: Modifier = Modifier,
    row: @Composable () -> Unit,
) {
    SectionCard(modifier = modifier) {
        repeat(rowCount) { index ->
            SectionCardItem(
                showDivider = index != rowCount - 1,
                isFirst = index == 0,
                isLast = index == rowCount - 1,
            ) {
                row()
            }
        }
    }
}

@Composable
fun SectionSkeleton(
    title: String,
    rowCount: Int,
    modifier: Modifier = Modifier,
    topPadding: Dp = 0.dp,
    row: @Composable () -> Unit,
) {
    SectionHeader(
        title = title,
        modifier = Modifier.padding(
            top = topPadding,
            bottom = 10.dp,
        ),
    )
    SectionCardSkeleton(
        rowCount = rowCount,
        modifier = modifier,
        row = row,
    )
}
