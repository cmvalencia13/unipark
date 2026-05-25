package com.unipark.android.presentation.permits

import androidx.lifecycle.ViewModel
import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.PricingOption
import com.unipark.android.domain.model.VehicleInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class PermitsViewModel @Inject constructor() : ViewModel() {

    private val _permits = MutableStateFlow(fakePermits)
    val permits: StateFlow<List<PermitInfo>> = _permits.asStateFlow()

    private val _vehicles = MutableStateFlow(fakeVehicles)
    val vehicles: StateFlow<List<VehicleInfo>> = _vehicles.asStateFlow()

    private val _pricingOptions = MutableStateFlow(fakePricing)
    val pricingOptions: StateFlow<List<PricingOption>> = _pricingOptions.asStateFlow()

    companion object {
        val fakePermits = listOf(
            PermitInfo(
                permitName = "Semester Parking",
                status = "Active",
                validUntil = "Dec 31, 2026",
                vehiclePlate = "ABC 1234",
            ),
        )

        val fakeVehicles = listOf(
            VehicleInfo(
                plate = "ABC 1234",
                makeModel = "Toyota Camry",
                isGuest = false,
            ),
            VehicleInfo(
                plate = "XYZ 9876",
                makeModel = "Honda Civic",
                isGuest = true,
                validUntil = "Today, 6:00 PM",
            ),
        )

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
