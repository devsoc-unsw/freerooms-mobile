package com.devsoc.freerooms.features

import com.devsoc.freerooms.GetBuildingsQuery
import com.devsoc.freerooms.core.network.GraphQLClient
import com.devsoc.freerooms.core.network.NetworkResult
import com.devsoc.freerooms.core.ui.ResponseState
import com.devsoc.freerooms.features.buildings.data.LiveBuildingRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking
import org.junit.Assert
import org.junit.Before
import org.junit.Test

class LiveBuildingRepositoryTest {

    private lateinit var graphQLClient: GraphQLClient
    private lateinit var repository: LiveBuildingRepository

    @Before
    fun setUp() {
        graphQLClient = mockk()
        repository = LiveBuildingRepository(graphQLClient)
    }

    @Test
    fun `getBuildings success returns Loading then Success`() = runBlocking {
        // Given
        val mockData = GetBuildingsQuery.Data(
            buildings = listOf(
                GetBuildingsQuery.Building(
                    id = "1",
                    name = "Building 1",
                    lat = -33.917,
                    long = 151.231,
                    aliases = listOf("B1")
                )
            )
        )
        coEvery { graphQLClient.query(any<GetBuildingsQuery>()) } returns NetworkResult.Success(
            mockData
        )

        // When
        val result = repository.getBuildings().toList()

        // Then
        Assert.assertEquals(2, result.size)
        Assert.assertTrue(result[0] is ResponseState.Loading)
        Assert.assertTrue(result[1] is ResponseState.Success)

        val successData = (result[1] as ResponseState.Success).data
        Assert.assertEquals(1, successData.size)
        Assert.assertEquals("Building 1", successData[0].name)
        Assert.assertEquals("1", successData[0].id)
    }

    @Test
    fun `getBuildings failure returns Loading then Error`() = runBlocking {
        // Given
        val errorMessage = "API Error"
        coEvery { graphQLClient.query(any<GetBuildingsQuery>()) } returns NetworkResult.Error(
            errorMessage
        )

        // When
        val result = repository.getBuildings().toList()

        // Then
        Assert.assertEquals(2, result.size)
        Assert.assertTrue(result[0] is ResponseState.Loading)
        Assert.assertTrue(result[1] is ResponseState.Error)
        Assert.assertEquals(errorMessage, (result[1] as ResponseState.Error).exception.message)
    }
}