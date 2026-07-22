package com.devsoc.freerooms.core.ui

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext

class BrowseUiPreferences(context: Context) {
    private val preferences: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun getViewMode(key: String): ListViewMode {
        val stored = preferences.getString(viewModeKey(key), ListViewMode.LIST.name)
        return runCatching { ListViewMode.valueOf(stored.orEmpty()) }
            .getOrDefault(ListViewMode.LIST)
    }

    fun setViewMode(key: String, mode: ListViewMode) {
        preferences.edit().putString(viewModeKey(key), mode.name).apply()
    }

    fun isAscending(key: String): Boolean {
        return preferences.getBoolean(ascendingKey(key), true)
    }

    fun setAscending(key: String, ascending: Boolean) {
        preferences.edit().putBoolean(ascendingKey(key), ascending).apply()
    }

    private fun viewModeKey(key: String) = "${key}_view_mode"

    private fun ascendingKey(key: String) = "${key}_ascending"

    companion object {
        const val Buildings = "buildings"
        const val Rooms = "rooms"
        private const val PREFS_NAME = "freerooms_browse_ui"
    }
}

@Composable
fun rememberBrowseUiPreferences(): BrowseUiPreferences {
    val context = LocalContext.current
    return remember(context) { BrowseUiPreferences(context) }
}
