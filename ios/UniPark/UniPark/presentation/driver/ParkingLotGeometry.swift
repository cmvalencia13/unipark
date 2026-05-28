import Foundation
import MapKit
import SwiftUI

public struct LotZone: Identifiable {
    public let id = UUID()
    public let name: String
    public let coordinates: [CLLocationCoordinate2D]
    public let kind: ZoneKind
    public enum ZoneKind { case outer, inner }
}

public struct ParkingLotAnnotation: Identifiable {
    public let id = UUID()
    public let coordinate: CLLocationCoordinate2D
    public let title: String
    public let availableSpots: Int
    public let totalSpots: Int
}

extension LotZone {
    // Outer boundary — full perimeter of Parqueo Key
    public static let parkingKeyOuter = LotZone(
        name: "Parqueo Key",
        coordinates: [
            CLLocationCoordinate2D(latitude: 13.680210122389441, longitude: -89.25347279543529),
            CLLocationCoordinate2D(latitude: 13.680272017660446, longitude: -89.25334539050634),
            CLLocationCoordinate2D(latitude: 13.680879241990954, longitude: -89.25377521450173),
            CLLocationCoordinate2D(latitude: 13.680839498816082, longitude: -89.25390060777389),
            CLLocationCoordinate2D(latitude: 13.680592774238331, longitude: -89.25393748571777),
            CLLocationCoordinate2D(latitude: 13.680555522984136, longitude: -89.25392379323479),
            CLLocationCoordinate2D(latitude: 13.680348867120747, longitude: -89.25376313476218),
            CLLocationCoordinate2D(latitude: 13.680454412412706, longitude: -89.25359608646397),
        ],
        kind: .outer
    )

    // Inner section — the two facing rows inside the lot
    public static let parkingKeyInner = LotZone(
        name: "Zona Interior",
        coordinates: [
            CLLocationCoordinate2D(latitude: 13.680466829502755, longitude: -89.25372570864072),
            CLLocationCoordinate2D(latitude: 13.680525367204227, longitude: -89.25365359489449),
            CLLocationCoordinate2D(latitude: 13.680692110880106, longitude: -89.25376861175558),
            CLLocationCoordinate2D(latitude: 13.680578583283815, longitude: -89.25381242770264),
        ],
        kind: .inner
    )

    // Parqueo Matías — estacionamiento exclusivo para estudiantes
    public static let parkingMatiasOuter = LotZone(
        name: "Parqueo Matías",
        coordinates: [
            CLLocationCoordinate2D(latitude: 13.680323974054101, longitude: -89.25411001529224),
            CLLocationCoordinate2D(latitude: 13.680324679516982, longitude: -89.25450644457504),
            CLLocationCoordinate2D(latitude: 13.679876004700510, longitude: -89.25447159364909),
            CLLocationCoordinate2D(latitude: 13.679879532021591, longitude: -89.25416156562022),
        ],
        kind: .outer
    )

    public static let parkingMatiasCenter = CLLocationCoordinate2D(
        latitude: (13.680323974054101 + 13.679876004700510) / 2,
        longitude: (-89.25411001529224 + -89.25450644457504) / 2
    )
}
