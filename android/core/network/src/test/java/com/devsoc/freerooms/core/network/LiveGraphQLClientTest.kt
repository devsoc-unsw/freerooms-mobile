package com.devsoc.freerooms.core.network

import android.util.Log
import com.apollographql.apollo.ApolloCall
import com.apollographql.apollo.ApolloClient
import com.apollographql.apollo.api.ApolloResponse
import com.apollographql.apollo.api.Query
import com.apollographql.apollo.exception.ApolloException
import io.mockk.coEvery
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import kotlinx.coroutines.runBlocking
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import java.util.UUID

class LiveGraphQLClientTest {

    private lateinit var apolloClient: ApolloClient
    private lateinit var liveGraphQLClient: LiveGraphQLClient

    @Before
    fun setUp() {
        mockkStatic(Log::class)
        every { Log.d(any(), any()) } returns 0
        every { Log.e(any(), any()) } returns 0
        every { Log.e(any(), any(), any()) } returns 0

        apolloClient = mockk()
        liveGraphQLClient = LiveGraphQLClient(apolloClient)
    }

    @Test
    fun `query success returns NetworkResult Success`() = runBlocking {
        val mockQuery = mockk<Query<Query.Data>>()
        val mockData = mockk<Query.Data>()
        val mockCall = mockk<ApolloCall<Query.Data>>()
        val mockResponse = ApolloResponse.Builder(
            operation = mockQuery,
            requestUuid = UUID.randomUUID(),
        ).data(mockData).build()

        every { apolloClient.query(mockQuery) } returns mockCall
        coEvery { mockCall.execute() } returns mockResponse

        val result = liveGraphQLClient.query(mockQuery)

        Assert.assertTrue(result is NetworkResult.Success)
        Assert.assertEquals(mockData, (result as NetworkResult.Success).data)
    }

    @Test
    fun `query failure returns NetworkResult Error`() = runBlocking {
        val mockQuery = mockk<Query<Query.Data>>()
        val mockCall = mockk<ApolloCall<Query.Data>>()
        val exceptionMessage = "Network error"
        val mockException = mockk<ApolloException>()
        every { mockException.message } returns exceptionMessage

        every { apolloClient.query(mockQuery) } returns mockCall
        coEvery { mockCall.execute() } throws mockException

        val result = liveGraphQLClient.query(mockQuery)

        Assert.assertTrue(result is NetworkResult.Error)
        Assert.assertEquals(exceptionMessage, (result as NetworkResult.Error).message)
    }
}
