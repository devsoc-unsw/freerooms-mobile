package com.devsoc.freerooms.core.network

import org.json.JSONObject

fun parseRoomBookings(json: String): RemoteRoomBookings {
    val root = JSONObject(json)
    val bookingsJson = root.optJSONArray("bookings")
    val bookings = buildList {
        if (bookingsJson != null) {
            for (index in 0 until bookingsJson.length()) {
                val booking = bookingsJson.getJSONObject(index)
                add(
                    RemoteRoomBooking(
                        name = booking.optString("name", ""),
                        bookingType = booking.optString("bookingType", ""),
                        start = booking.optString("start", ""),
                        end = booking.optString("end", ""),
                    ),
                )
            }
        }
    }

    return RemoteRoomBookings(
        id = root.optString("id", ""),
        name = root.optString("name", ""),
        bookings = bookings,
    )
}
