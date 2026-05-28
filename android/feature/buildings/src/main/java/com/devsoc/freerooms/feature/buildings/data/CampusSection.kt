package com.devsoc.freerooms.feature.buildings.data

enum class CampusSection {
    LOWER,
    MIDDLE,
    UPPER;

    companion object {
        fun fromSectionNumber(sectionNumber: Int): CampusSection {
            return when (sectionNumber) {
                in 1..10 -> LOWER
                in 11..18 -> MIDDLE
                in 19..28 -> UPPER
                else -> UPPER
            }
        }
    }
}
