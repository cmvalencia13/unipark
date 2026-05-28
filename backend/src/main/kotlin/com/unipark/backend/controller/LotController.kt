package com.unipark.backend.controller

import com.unipark.backend.domain.ParkingLot
import com.unipark.backend.repository.ParkingLotRepository
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/v1/lots")
class LotController(
    private val parkingLotRepository: ParkingLotRepository
) {

    @GetMapping
    fun getAllLots(): List<ParkingLot> {
        return parkingLotRepository.findAll()
    }
}
