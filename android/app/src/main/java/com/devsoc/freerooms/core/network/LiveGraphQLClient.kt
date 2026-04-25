package com.devsoc.freerooms.core.network

import com.apollographql.apollo.ApolloClient
import com.apollographql.apollo.api.Query
import org.koin.core.annotation.Single

@Single(binds = [GraphQLClient::class])
class LiveGraphQLClient(
    private val apolloClient: ApolloClient = ApolloClient.Builder()
        .serverUrl(NetworkConstants.SERVER_URL)
        .build()
) : GraphQLClient {
    override suspend fun <D : Query.Data> query(query: Query<D>): NetworkResult<D> {
        return try {
            val response = apolloClient.query(query).execute()
            if (response.data != null) {
                NetworkResult.Success(response.data!!)
            } else {
                val errorMessage = response.errors?.firstOrNull()?.message ?: "Unknown error"
                NetworkResult.Error(errorMessage)
            }
        } catch (e: Exception) {
            NetworkResult.Error(e.message ?: "An unexpected error occurred", e)
        }
    }
}
