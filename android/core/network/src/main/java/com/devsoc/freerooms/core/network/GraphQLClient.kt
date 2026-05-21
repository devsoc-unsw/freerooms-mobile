package com.devsoc.freerooms.core.network

import com.apollographql.apollo.api.Query

interface GraphQLClient {
    suspend fun <D : Query.Data> query(query: Query<D>): NetworkResult<D>
}
