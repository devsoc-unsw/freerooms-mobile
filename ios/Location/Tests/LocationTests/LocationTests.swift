import CoreLocation
import Testing
@testable import Location

// MARK: - LocationServicePermissionTest

struct LocationServicePermissionTest {

  @Test("userAuthorizationStatus denied on initiliaze")
  func requestLocationPermissionDeniedOnInitialize() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()

    // When
    spyLocationManager.authorizationStatus = .denied
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)
    let sut = LiveLocationService(locationManager: spyLocationManager)

    // Then
    #expect(sut.currentPermissionState == .denied)
  }

  @Test("userAuthorizationStatus unrequested on initialize")
  func requestLocationPermissionUnrequestedOnInitialize() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()
    spyLocationManager.authorizationStatus = .notDetermined
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    // when
    let sut = LiveLocationService(locationManager: spyLocationManager)

    // Then
    #expect(sut.currentPermissionState == .unrequested)
  }

  @Test("userAuthorizationStatus granted on initialize")
  func requestLocationPermissionGrantedOnInitialize() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()
    spyLocationManager.authorizationStatus = .authorizedWhenInUse
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    // When
    let sut = LiveLocationService(locationManager: spyLocationManager)

    // Then
    #expect(sut.currentPermissionState == .granted)
  }

  @Test("user request permission on pending permissionState")
  func requestLocationPermissionOnPendingState() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()
    spyLocationManager.authorizationStatus = .notDetermined
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    // When
    let sut = LiveLocationService(locationManager: spyLocationManager)

    // Then
    #expect(throws: Never.self) {
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()

      #expect(hasPermissionApiBeenCalled == true)
      #expect(sut.currentPermissionState == .pending)
    }

    #expect(throws: Never.self) {
      // request user location permission again
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()

      // expect early false return
      #expect(hasPermissionApiBeenCalled == false)
      #expect(sut.currentPermissionState == .pending)
      #expect(spyLocationManager.requestWhenInUseAuthorizationCallCount == 1)
    }
  }

  @Test("user deny access on authorize")
  func requestLocationPermissionDeniedWhenAuthorized() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()
    spyLocationManager.authorizationStatus = .notDetermined
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    let sut = LiveLocationService(locationManager: spyLocationManager)

    #expect(sut.locationManager.authorizationStatus == .notDetermined)

    #expect(throws: Never.self) {
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()
      #expect(hasPermissionApiBeenCalled == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // When
    spyLocationManager.authorizationStatus = .denied
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    // Then
    #expect(throws: LocationServiceError.locationPermissionsDenied) {
      try sut.requestLocationPermissions()
    }
    #expect(spyLocationManager.requestWhenInUseAuthorizationCallCount == 1)
  }

  @Test("user grant access on authorize")
  func requestLocationPermissionGrantedWhenAuthorized() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()

    let sut = LiveLocationService(locationManager: spyLocationManager)
    #expect(sut.currentPermissionState == LocationPermission.unrequested)
    #expect(throws: Never.self) {
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()
      #expect(hasPermissionApiBeenCalled == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // When
    spyLocationManager.authorizationStatus = .authorizedWhenInUse
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)

    // Then
    #expect(sut.currentPermissionState == .granted)
    #expect(spyLocationManager.requestWhenInUseAuthorizationCallCount == 1)
  }
}

// MARK: - GetUserLocationTest

struct GetUserLocationTest {
  @Test("get user location when permission not granted")
  func requestUserLocationWhenPermissionNotGranted() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()

    let sut = LiveLocationService(locationManager: spyLocationManager)

    // When
    spyLocationManager.authorizationStatus = .denied
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)
    spyLocationManager.location = Location(latitude: 300, longitude: 300)

    // Then
    #expect(throws: LocationServiceError.locationPermissionsDenied) {
      try sut.getCurrentLocation()
    }
  }

  @Test("Get user location when location unavailable")
  func requestUserLocationWhenLocationNotAvailable() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()

    let sut = LiveLocationService(locationManager: spyLocationManager)

    // When
    spyLocationManager.authorizationStatus = .authorizedWhenInUse
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)
    spyLocationManager.location = nil

    // Then
    #expect(throws: LocationServiceError.locationNotAvailable) {
      try sut.getCurrentLocation()
    }
  }

  @Test("get user location when permission granted")
  func requestUserLocationWhenGrantedAndAvailable() async throws {
    // Given
    let spyLocationManager = SpyLocationManager()

    let sut = LiveLocationService(locationManager: spyLocationManager)

    // When
    spyLocationManager.authorizationStatus = .authorizedWhenInUse
    spyLocationManager.delegate?.locationManagerDidChangeAuthorization(spyLocationManager)
    spyLocationManager.location = Location(latitude: 300, longitude: 300)

    // Then
    #expect(throws: Never.self) {
      let location = try sut.getCurrentLocation()

      #expect(location == Location(latitude: 300, longitude: 300))
    }
  }
}

// MARK: - LocationDistanceTests

struct LocationDistanceTests {

  // MARK: Internal

  @Test("Distance from a location to itself is zero")
  func distanceToSelfIsZero() {
    // Given
    let location = unswCentre

    // When
    let distance = location.distance(to: location)

    // Then
    #expect(distance == 0)
  }

  @Test("A point 0.001° north is about 111 metres away")
  func distanceForSmallLatitudeChange() {
    // Given
    let north = Location(latitude: unswCentre.latitude + 0.001, longitude: unswCentre.longitude)

    // When
    let distance = unswCentre.distance(to: north)

    // Then
    #expect((105...117).contains(distance))
  }

  @Test("A degree of longitude is shorter than a degree of latitude away from the equator")
  func longitudeIsShorterThanLatitudeAtUNSW() {
    // Given
    let north = Location(latitude: unswCentre.latitude + 0.001, longitude: unswCentre.longitude)
    let east = Location(latitude: unswCentre.latitude, longitude: unswCentre.longitude + 0.001)

    // When
    let northDistance = unswCentre.distance(to: north)
    let eastDistance = unswCentre.distance(to: east)

    // Then: at ~34° south, east-west degrees are about cos(34°) ≈ 0.83 times as long.
    #expect(eastDistance < northDistance)
    #expect((88...97).contains(eastDistance))
  }

  @Test("Distance is the same in both directions")
  func distanceIsSymmetric() {
    // Given
    let library = Location(latitude: -33.9177, longitude: 151.2334)

    // When
    let there = unswCentre.distance(to: library)
    let back = library.distance(to: unswCentre)

    // Then
    #expect(abs(there - back) < 0.001)
  }

  // MARK: Private

  /// Roughly the middle of UNSW Kensington.
  private let unswCentre = Location(latitude: -33.9173, longitude: 151.2312)
}
