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
