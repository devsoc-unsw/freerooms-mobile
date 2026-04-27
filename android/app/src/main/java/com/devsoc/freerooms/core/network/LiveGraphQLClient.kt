package com.devsoc.freerooms.core.network

import android.util.Log
import com.apollographql.apollo.ApolloClient
import com.apollographql.apollo.api.Query

class LiveGraphQLClient(
    private val apolloClient: ApolloClient
) : GraphQLClient {
    override suspend fun <D : Query.Data> query(query: Query<D>): NetworkResult<D> {
        Log.d("LiveGraphQLClient", "Executing query: ${query::class.java.simpleName}")
        return try {
            val response = apolloClient.query(query).execute()
            
            Log.d("LiveGraphQLClient", "Response received. hasData: ${response.data != null}, errors: ${response.errors?.size ?: 0}")
            
            if (response.exception != null) {
                Log.e("LiveGraphQLClient", "Apollo Exception: ${response.exception?.message}", response.exception)
            }

            val data = response.data
            if (data != null) {
                NetworkResult.Success(data)
            } else {
                val errorMessage = response.errors?.firstOrNull()?.message 
                    ?: response.exception?.message
                    ?: "Unknown error (Data is null and no errors returned)"
                
                Log.e("LiveGraphQLClient", "GraphQL Error: $errorMessage")
                response.errors?.forEach { 
                    Log.e("LiveGraphQLClient", "Detailed Error: ${it.message}")
                }

                NetworkResult.Error(errorMessage, response.exception)
            }
        } catch (e: Exception) {
            Log.e("LiveGraphQLClient", "Network/Apollo Exception", e)
            NetworkResult.Error(e.message ?: "An unexpected error occurred", e)
        }
    }
}
