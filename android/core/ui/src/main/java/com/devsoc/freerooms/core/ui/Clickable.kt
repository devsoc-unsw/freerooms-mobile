package com.devsoc.freerooms.core.ui

import androidx.compose.foundation.IndicationNodeFactory
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.InteractionSource
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.node.DelegatableNode

internal object NoIndication : IndicationNodeFactory {
    override fun create(interactionSource: InteractionSource): DelegatableNode {
        return object : Modifier.Node() {}
    }

    override fun hashCode(): Int = -1

    override fun equals(other: Any?): Boolean = other === this
}

@Composable
fun Modifier.freeroomsClickable(
    enabled: Boolean = true,
    onClick: () -> Unit,
): Modifier {
    return combinedClickable(
        enabled = enabled,
        interactionSource = remember { MutableInteractionSource() },
        indication = null,
        onClick = onClick,
        onLongClick = {},
    )
}
