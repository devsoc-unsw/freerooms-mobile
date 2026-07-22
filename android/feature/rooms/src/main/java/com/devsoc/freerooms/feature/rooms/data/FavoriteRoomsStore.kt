package com.devsoc.freerooms.feature.rooms.data

import android.content.Context
import android.content.SharedPreferences

class FavoriteRoomsStore(context: Context) {
    private val preferences: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun isFavorite(roomId: String): Boolean {
        return preferences.getStringSet(KEY_FAVORITES, emptySet()).orEmpty().contains(roomId)
    }

    fun toggleFavorite(roomId: String): Boolean {
        val current = preferences.getStringSet(KEY_FAVORITES, emptySet()).orEmpty().toMutableSet()
        val isNowFavorite = if (current.contains(roomId)) {
            current.remove(roomId)
            false
        } else {
            current.add(roomId)
            true
        }
        preferences.edit().putStringSet(KEY_FAVORITES, current).apply()
        return isNowFavorite
    }

    companion object {
        private const val PREFS_NAME = "freerooms_favorites"
        private const val KEY_FAVORITES = "favorite_room_ids"
    }
}
