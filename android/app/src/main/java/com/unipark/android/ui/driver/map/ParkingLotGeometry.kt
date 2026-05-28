package com.unipark.android.ui.driver.map

import org.osmdroid.util.GeoPoint

object ParkingLotGeometry {
    val parkingKeyOuter = listOf(
        GeoPoint(13.680210122389441, -89.25347279543529),
        GeoPoint(13.680272017660446, -89.25334539050634),
        GeoPoint(13.680879241990954, -89.25377521450173),
        GeoPoint(13.680839498816082, -89.25390060777389),
        GeoPoint(13.680592774238331, -89.25393748571777),
        GeoPoint(13.680555522984136, -89.25392379323479),
        GeoPoint(13.680348867120747, -89.25376313476218),
        GeoPoint(13.680454412412706, -89.25359608646397),
    )

    val parkingKeyInner = listOf(
        GeoPoint(13.680466829502755, -89.25372570864072),
        GeoPoint(13.680525367204227, -89.25365359489449),
        GeoPoint(13.680692110880106, -89.25376861175558),
        GeoPoint(13.680578583283815, -89.25381242770264),
    )

    val center = GeoPoint(13.680524, -89.253714)
}
