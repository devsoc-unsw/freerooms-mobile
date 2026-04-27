package com.devsoc.freerooms.features.buildings.data

// TODO: Add adapter for the GraphQL scalar type _text (List of strings) to add back aliases
data class Building(val id: String, val name: String, val lat: Double, val long: Double)