package com.devsoc.freerooms.feature.buildings.data

data class Building(
    val id: String,
    val name: String,
    val lat: Double,
    val long: Double,
    val numberOfAvailableRooms: Int? = null,
    val overallRating: Double? = null,
) {
    val gridReference: GridReference
        get() = GridReference.fromBuildingId(id)

    val campusSection: CampusSection
        get() = gridReference.campusSection
}
