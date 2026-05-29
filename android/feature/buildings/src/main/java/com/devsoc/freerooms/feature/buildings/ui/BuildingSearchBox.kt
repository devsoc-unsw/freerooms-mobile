package com.devsoc.freerooms.feature.buildings.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.devsoc.freerooms.core.ui.Gray2
import com.devsoc.freerooms.core.ui.Gray3

@Composable
internal fun BuildingSearchBox(
    modifier: Modifier = Modifier,
) {
    var searchText by rememberSaveable { mutableStateOf("") }

    BasicTextField(
        value = searchText,
        onValueChange = { searchText = it },
        modifier = modifier
            .fillMaxWidth()
            .height(48.dp)
            .background(Gray2, RoundedCornerShape(12.dp))
            .padding(horizontal = 16.dp),
        singleLine = true,
        textStyle = MaterialTheme.typography.bodyLarge.copy(color = Gray3),
        decorationBox = { innerTextField ->
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.CenterStart,
            ) {
                if (searchText.isEmpty()) {
                    Text(
                        text = "Search",
                        style = MaterialTheme.typography.bodyLarge,
                        color = Gray3,
                    )
                }

                innerTextField()
            }
        },
    )
}
