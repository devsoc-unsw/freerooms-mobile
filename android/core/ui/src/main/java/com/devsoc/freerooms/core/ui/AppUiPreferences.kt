package com.devsoc.freerooms.core.ui

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext

class AppUiPreferences(context: Context) {
    private val preferences: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun isDarkMode(): Boolean = preferences.getBoolean(KEY_DARK_MODE, false)

    fun setDarkMode(enabled: Boolean) {
        preferences.edit().putBoolean(KEY_DARK_MODE, enabled).apply()
    }

    fun use12HourClock(): Boolean = preferences.getBoolean(KEY_12_HOUR, false)

    fun setUse12HourClock(enabled: Boolean) {
        preferences.edit().putBoolean(KEY_12_HOUR, enabled).apply()
    }

    companion object {
        private const val PREFS_NAME = "freerooms_app_ui"
        private const val KEY_DARK_MODE = "dark_mode"
        private const val KEY_12_HOUR = "use_12_hour_clock"
    }
}

data class AppUiSettings(
    val darkMode: Boolean,
    val use12HourClock: Boolean,
    val setDarkMode: (Boolean) -> Unit,
    val setUse12HourClock: (Boolean) -> Unit,
)

val LocalAppUiSettings = staticCompositionLocalOf<AppUiSettings> {
    error("LocalAppUiSettings not provided")
}

@Composable
fun rememberAppUiPreferences(): AppUiPreferences {
    val context = LocalContext.current
    return remember(context) { AppUiPreferences(context) }
}
