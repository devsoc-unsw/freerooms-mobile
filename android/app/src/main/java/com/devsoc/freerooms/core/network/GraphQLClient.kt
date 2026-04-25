package com.devsoc.freerooms.core.network

import com.apollographql.apollo.api.Query

interface GraphQLClient {
    /**
     * Executes a GraphQL query and returns a [NetworkResult].
     */
    suspend fun <D : Query.Data> query(query: Query<D>): NetworkResult<D>
}
