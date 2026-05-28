package com.unipark.android.domain.model

sealed class Resource<out T> {
    data class Success<out T>(val data: T) : Resource<T>()
    data class Error(
        val message: String,
        val title: String? = null,
        val status: Int? = null,
        val type: String? = null,
        val detail: String? = null
    ) : Resource<Nothing>()
    object Loading : Resource<Nothing>()
}
