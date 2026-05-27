package com.unipark.android.presentation.permits

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.PricingOption
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.model.VehicleInfo
import com.unipark.android.domain.repository.PassRepository
import com.unipark.android.domain.repository.UserRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PermitsViewModel @Inject constructor(
    private val userRepository: UserRepository,
    private val passRepository: PassRepository
) : ViewModel() {

    private val _permits = MutableStateFlow<List<PermitInfo>>(emptyList())
    val permits: StateFlow<List<PermitInfo>> = _permits.asStateFlow()

    private val _vehicles = MutableStateFlow<List<VehicleInfo>>(emptyList())
    val vehicles: StateFlow<List<VehicleInfo>> = _vehicles.asStateFlow()

    private val _pricingOptions = MutableStateFlow(fakePricing)
    val pricingOptions: StateFlow<List<PricingOption>> = _pricingOptions.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            passRepository.getActivePermits().collect { resource ->
                if (resource is Resource.Success) {
                    _permits.value = resource.data
                }
            }
        }
        viewModelScope.launch {
            userRepository.getUserVehicles().collect { resource ->
                if (resource is Resource.Success) {
                    _vehicles.value = resource.data
                }
            }
        }
    }

    companion object {
        val fakePricing = listOf(
            PricingOption(
                name = "Semester Pass",
                price = "$150",
                description = "Full semester access to all campus lots. Best value for daily commuters.",
                highlight = false,
            ),
            PricingOption(
                name = "Monthly Pass",
                price = "$45/mo",
                description = "Flexible monthly billing. Pause or cancel anytime. Ideal for part-time students.",
                highlight = true,
            ),
            PricingOption(
                name = "Daily 5-Pack",
                price = "$25",
                description = "Five daily passes at a discount. Perfect for occasional visitors and guests.",
                highlight = false,
            ),
        )
    }
}
