package com.devsoc.freerooms.core.network

import com.apollographql.apollo.api.Adapter
import com.apollographql.apollo.api.CustomScalarAdapters
import com.apollographql.apollo.api.json.JsonReader
import com.apollographql.apollo.api.json.JsonWriter

object TextListAdapter : Adapter<List<String>> {
    override fun fromJson(
        reader: JsonReader,
        customScalarAdapters: CustomScalarAdapters,
    ): List<String> {
        val values = mutableListOf<String>()
        reader.beginArray()
        while (reader.hasNext()) {
            when (reader.peek()) {
                JsonReader.Token.STRING -> values.add(reader.nextString().orEmpty())
                JsonReader.Token.NULL -> {
                    reader.skipValue()
                }
                else -> reader.skipValue()
            }
        }
        reader.endArray()
        return values
    }

    override fun toJson(
        writer: JsonWriter,
        customScalarAdapters: CustomScalarAdapters,
        value: List<String>,
    ) {
        writer.beginArray()
        value.forEach { writer.value(it) }
        writer.endArray()
    }
}
