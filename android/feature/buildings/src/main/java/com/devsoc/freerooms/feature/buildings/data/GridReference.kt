package com.devsoc.freerooms.feature.buildings.data

data class GridReference(
    val campusCode: String,
    val sectionCode: String,
    val sectionNumber: Int,
    val campusSection: CampusSection,
) {
    companion object {
        fun fromBuildingId(buildingId: String): GridReference {
            val parts = buildingId.split("-")
            if (parts.size != GRID_REFERENCE_PARTS) return default()

            val campusCode = parts[0]
            val section = parts[1]
            if (section.length < MIN_SECTION_LENGTH) return default()

            val sectionCode = section.first().toString()
            val sectionNumber = section.drop(1).toIntOrNull() ?: return default()

            return GridReference(
                campusCode = campusCode,
                sectionCode = sectionCode,
                sectionNumber = sectionNumber,
                campusSection = CampusSection.fromSectionNumber(sectionNumber),
            )
        }

        private fun default(): GridReference {
            return GridReference(
                campusCode = "?",
                sectionCode = "?",
                sectionNumber = 0,
                campusSection = CampusSection.UPPER,
            )
        }

        private const val GRID_REFERENCE_PARTS = 2
        private const val MIN_SECTION_LENGTH = 2
    }
}
