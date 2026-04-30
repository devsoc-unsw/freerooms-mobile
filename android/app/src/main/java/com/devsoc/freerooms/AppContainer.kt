package com.devsoc.freerooms

import android.util.Log
import com.apollographql.apollo.ApolloClient
import com.apollographql.apollo.network.okHttpClient
import com.devsoc.freerooms.core.network.LiveGraphQLClient
import com.devsoc.freerooms.core.network.NetworkConstants
import com.devsoc.freerooms.feature.buildings.data.LiveBuildingRepository
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor

class AppContainer {

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor { message ->
            Log.d("OkHttp", message)
        }.apply {
            level = HttpLoggingInterceptor.Level.BODY
        })
        .build()

    private val apolloClient = ApolloClient.Builder()
        .serverUrl(NetworkConstants.SERVER_URL)
        .okHttpClient(okHttpClient)
        .build()

    private val graphQLClient = LiveGraphQLClient(apolloClient)

    val buildingRepository = LiveBuildingRepository(graphQLClient)
}
