package com.devsoc.freerooms

import android.util.Log
import com.apollographql.apollo.ApolloClient
import com.apollographql.apollo.network.okHttpClient
import com.devsoc.freerooms.core.network.LiveBuildingRatingClient
import com.devsoc.freerooms.core.network.LiveGraphQLClient
import com.devsoc.freerooms.core.network.LiveRoomStatusClient
import com.devsoc.freerooms.core.network.NetworkConstants
import com.devsoc.freerooms.feature.buildings.data.LiveBuildingRepository
import com.devsoc.freerooms.feature.rooms.data.LiveRoomRepository
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor

class AppContainer {

    private val okHttpClient = OkHttpClient.Builder()
        .apply {
            if (BuildConfig.DEBUG) {
                addInterceptor(HttpLoggingInterceptor { message ->
                    Log.d("OkHttp", message)
                }.apply {
                    level = HttpLoggingInterceptor.Level.BODY
                })
            }
        }
        .build()

    private val apolloClient = ApolloClient.Builder()
        .serverUrl(NetworkConstants.SERVER_URL)
        .okHttpClient(okHttpClient)
        .build()

    private val graphQLClient = LiveGraphQLClient(apolloClient)
    private val roomStatusClient = LiveRoomStatusClient(okHttpClient)
    private val buildingRatingClient = LiveBuildingRatingClient(okHttpClient)

    val buildingRepository = LiveBuildingRepository(
        graphQLClient,
        roomStatusClient,
        buildingRatingClient,
    )
    val roomRepository = LiveRoomRepository(graphQLClient)
}
