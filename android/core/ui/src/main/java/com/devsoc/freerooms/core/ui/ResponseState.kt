package com.devsoc.freerooms.core.ui

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onStart

sealed interface ResponseState<out T> {
    data class Success<T>(val data: T): ResponseState<T>
    data class Error(val exception: Throwable): ResponseState<Nothing>
    data object Loading: ResponseState<Nothing>
}

fun <T, R> Flow<T>.asResponseState(
    transform: (T) -> R
): Flow<ResponseState<R>> {
    return this
        .map<T, ResponseState<R>> {
            ResponseState.Success(transform(it))
        }
        .onStart {
            emit(ResponseState.Loading)
        }
        .catch {
            emit(ResponseState.Error(it))
        }
}

fun <T> Flow<T>.asResponseState(): Flow<ResponseState<T>> {
    return this.asResponseState { it }
}
