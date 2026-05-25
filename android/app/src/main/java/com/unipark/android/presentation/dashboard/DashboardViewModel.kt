package com.unipark.android.presentation.dashboard

import androidx.lifecycle.ViewModel
import com.unipark.android.domain.model.AlertItem
import com.unipark.android.domain.model.AlertType
import com.unipark.android.domain.model.LocationInfo
import com.unipark.android.domain.model.OccupancyData
import com.unipark.android.domain.model.PermitInfo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class DashboardViewModel @Inject constructor() : ViewModel() {

    private val _permit = MutableStateFlow(fakePermit)
    val permit: StateFlow<PermitInfo> = _permit.asStateFlow()

    private val _location = MutableStateFlow(fakeLocation)
    val location: StateFlow<LocationInfo> = _location.asStateFlow()

    private val _occupancy = MutableStateFlow(fakeOccupancy)
    val occupancy: StateFlow<List<OccupancyData>> = _occupancy.asStateFlow()

    private val _alerts = MutableStateFlow(fakeAlerts)
    val alerts: StateFlow<List<AlertItem>> = _alerts.asStateFlow()

    companion object {
        val fakePermit = PermitInfo(
            permitName = "Semester Parking",
            status = "Active",
            validUntil = "Dec 31, 2026",
            vehiclePlate = "ABC 1234",
        )

        val fakeLocation = LocationInfo(
            lotName = "Main Campus Garage",
            spotNumber = "A-47",
            parkedSince = "Today, 8:30 AM",
        )

        val fakeOccupancy = listOf(
            OccupancyData(lotName = "Main Campus Garage", percentage = 72),
            OccupancyData(lotName = "West Lot", percentage = 91),
            OccupancyData(lotName = "South Deck", percentage = 45),
        )

        val fakeAlerts = listOf(
            AlertItem(
                title = "Lot Maintenance",
                body = "West Lot levels 2-3 closed for resurfacing May 28-30. Use South Deck as alternative.",
                timestamp = "2h ago",
                type = AlertType.Maintenance,
            ),
            AlertItem(
                title = "Event Parking",
                body = "Stadium event today at 6 PM. East Lot and Arena Deck reserved for attendees.",
                timestamp = "5h ago",
                type = AlertType.Info,
            ),
            AlertItem(
                title = "Permit Expiry",
                body = "Your semester permit expires Dec 31. Renewal opens Nov 15 with early-bird pricing.",
                timestamp = "1d ago",
                type = AlertType.Warning,
            ),
        )
    }
}
