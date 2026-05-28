package com.unipark.android.presentation.guard

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class GuardLotsViewModel @Inject constructor(
    guardStateStore: GuardStateStore,
) : ViewModel() {
    val lots = guardStateStore.lots
}
