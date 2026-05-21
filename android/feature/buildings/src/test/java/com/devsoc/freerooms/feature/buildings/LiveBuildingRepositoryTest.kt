package com.devsoc.freerooms.feature.buildings

import android.util.Log
import com.apollographql.apollo.ApolloClient
import com.devsoc.freerooms.core.network.LiveGraphQLClient
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.feature.buildings.data.LiveBuildingRepository
import io.mockk.every
import io.mockk.mockkStatic
import io.mockk.unmockkAll
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert
import org.junit.Before
import org.junit.Test

class LiveBuildingRepositoryTest {

    private lateinit var mockWebServer: MockWebServer
    private lateinit var repository: LiveBuildingRepository

    @Before
    fun setUp() {
        mockkStatic(Log::class)
        every { Log.d(any(), any()) } returns 0
        every { Log.e(any(), any()) } returns 0
        every { Log.e(any(), any(), any()) } returns 0

        mockWebServer = MockWebServer()
        val apolloClient = ApolloClient.Builder()
            .serverUrl(mockWebServer.url("/").toString())
            .build()

        val liveGraphQLClient = LiveGraphQLClient(apolloClient)
        repository = LiveBuildingRepository(liveGraphQLClient)
    }

    @After
    fun tearDown() {
        mockWebServer.shutdown()
        unmockkAll()
    }

    @Test
    fun `getBuildings success returns Loading then Success with correct data`() = runBlocking {
        val jsonResponse = """
            {
              "data": {
                "buildings": [
                  {
                    "id": "K-J17",
                    "name": "Ainsworth Building",
                    "lat": -33.918527,
                    "long": 151.23126
                  }
                ]
              }
            }
        """.trimIndent()

        mockWebServer.enqueue(MockResponse().setBody(jsonResponse))

        val result = repository.getBuildings().toList()

        Assert.assertEquals(2, result.size)
        Assert.assertTrue(result[0] is ResponseState.Loading)
        Assert.assertTrue(result[1] is ResponseState.Success)

        val successData = (result[1] as ResponseState.Success).data
        Assert.assertEquals(1, successData.size)
        val building = successData[0]
        Assert.assertEquals("K-J17", building.id)
        Assert.assertEquals("Ainsworth Building", building.name)
        Assert.assertEquals(-33.918527, building.lat, 0.0001)
        Assert.assertEquals(151.23126, building.long, 0.0001)
    }

    @Test
    fun `getBuildings failure returns Loading then Error`() = runBlocking {
        val jsonResponse = """
            {
              "errors": [
                {
                  "message": "API Error"
                }
              ]
            }
        """.trimIndent()

        mockWebServer.enqueue(MockResponse().setBody(jsonResponse))

        val result = repository.getBuildings().toList()

        Assert.assertEquals(2, result.size)
        Assert.assertTrue(result[0] is ResponseState.Loading)
        Assert.assertTrue(result[1] is ResponseState.Error)
        val errorState = result[1] as ResponseState.Error
        Assert.assertEquals("API Error", errorState.exception.message)
    }
}