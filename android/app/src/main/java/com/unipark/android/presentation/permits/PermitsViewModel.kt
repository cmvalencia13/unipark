package com.unipark.android.presentation.permits

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.unipark.android.domain.entities.Pass
import com.unipark.android.domain.model.PermitInfo
import com.unipark.android.domain.model.PricingOption
import com.unipark.android.domain.model.Resource
import com.unipark.android.domain.model.VehicleInfo
import com.unipark.android.domain.repositories.PassRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import javax.inject.Inject

@HiltViewModel
class PermitsViewModel @Inject constructor(
    private val passRepository: PassRepository
) : ViewModel() {

    private val _permitsState = MutableStateFlow<Resource<List<PermitInfo>>>(Resource.Loading)
    val permitsState: StateFlow<Resource<List<PermitInfo>>> = _permitsState.asStateFlow()

    private val _vehiclesState = MutableStateFlow<Resource<List<VehicleInfo>>>(Resource.Loading)
    val vehiclesState: StateFlow<Resource<List<VehicleInfo>>> = _vehiclesState.asStateFlow()

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
            _permitsState.value = Resource.Loading
            runCatching { passRepository.getActivePass() }
                .onSuccess { pass ->
                    val permits = pass?.let { listOf(it.toPermitInfo()) } ?: fakePermits
                    _permits.value = permits
                    _permitsState.value = Resource.Success(permits)
                }
                .onFailure { e ->
                    // Caída de gracia a mocks para desarrollo local
                    _permits.value = fakePermits
                    _permitsState.value = Resource.Error(e.message ?: "Error al cargar permisos")
                }
        }
        // El backend canónico no expone vehículos del usuario; se usan datos demo.
        _vehicles.value = fakeVehicles
        _vehiclesState.value = Resource.Success(fakeVehicles)
    }

    private fun Pass.toPermitInfo(): PermitInfo {
        val formatter = DateTimeFormatter.ofPattern("MMM d, yyyy").withZone(ZoneId.systemDefault())
        return PermitInfo(
            permitName = "Campus Parking",
            status = if (isExpired) "Expired" else "Active",
            validUntil = formatter.format(expiresAt),
            vehiclePlate = "—",
        )
    }

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
