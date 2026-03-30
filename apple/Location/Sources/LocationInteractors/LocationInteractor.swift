//
//  LocationInteractor.swift
//  Location
//
//  Created by Dicko Evaldo on 31/8/2025.
//
import CoreLocation
import Location

public class LocationInteractor {

  // MARK: Lifecycle

  public init(locationService: LocationService) {
    self.locationService = locationService
  }

  // MARK: Public

  public func requestLocationPermission() throws -> Bool {
    try locationService.requestLocationPermissions()
  }

  public func getUserLocation() throws -> Location {
    try locationService.getCurrentLocation()
  }

  public func setLocationUpdateCallback(_ callback: @escaping (Location) -> Void) {
    locationService.onLocationUpdate = callback
  }

  public func setHeadingUpdateCallback(_ callback: @escaping (CLHeading) -> Void) {
    locationService.onHeadingUpdate = callback
  }

  // MARK: Private

  private var locationService: LocationService
}
