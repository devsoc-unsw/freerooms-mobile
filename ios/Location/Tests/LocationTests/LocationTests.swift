import CoreLocation
import Testing
@testable import Location

// MARK: - LocationServicePermissionTest

struct LocationServicePermissionTest {

  @Test("userAuthorizationStatus denied on initiliaze")
  func requestLocationPermissionDeniedOnInitialize() async throws {
    // Given
    let mockLocationManager = MockLocationManager()

    // When
    mockLocationManager.simulateAuthorizationStatus(to: .denied)
    let sut = LocationService(locationManager: mockLocationManager)

    // Then
    #expect(sut.currentPermissionState == .denied)
  }

  @Test("userAuthorizationStatus unrequested on initialize")
  func requestLocationPermissionUnrequestedOnInitialize() async throws {
    // Given
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    // when
    let sut = LocationService(locationManager: mockLocationManager)

    // Then
    #expect(sut.currentPermissionState == .unrequested)
  }

  @Test("userAuthorizationStatus granted on initialize")
  func requestLocationPermissionGrantedOnInitialize() async throws {
    // Given
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    // When
    let sut = LocationService(locationManager: mockLocationManager)

    // Then
    #expect(sut.currentPermissionState == .granted)
  }

  @Test("user request permission on pending permissionState")
  func requestLocationPermissionOnPendingState() async throws {
    // Given
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    // When
    let sut = LocationService(locationManager: mockLocationManager)

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
      #expect(mockLocationManager.requestInUseAuthorizationCallTracker == 1)
    }
  }

  @Test("user deny access on authorize")
  func requestLocationPermissionDeniedWhenAuthorized() async throws {
    // Given
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    let sut = LocationService(locationManager: mockLocationManager)

    #expect(sut.locationManager.authorizationStatus == .notDetermined)

    #expect(throws: Never.self) {
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()
      #expect(hasPermissionApiBeenCalled == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // When
    mockLocationManager.simulateAuthorizationStatus(to: .denied)

    // Then
    #expect(throws: LocationServiceError.locationPermissionsDenied) {
      try sut.requestLocationPermissions()
    }
    #expect(mockLocationManager.requestInUseAuthorizationCallTracker == 1)
  }

  @Test("user grant access on authorize")
  func requestLocationPermissionGrantedWhenAuthorized() async throws {
    // Given
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)
    #expect(sut.currentPermissionState == LocationPermission.unrequested)
    #expect(throws: Never.self) {
      let hasPermissionApiBeenCalled = try sut.requestLocationPermissions()
      #expect(hasPermissionApiBeenCalled == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // When
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    // Then
    #expect(sut.currentPermissionState == .granted)
    #expect(mockLocationManager.requestInUseAuthorizationCallTracker == 1)
  }

}

// MARK: - MockLocationManager

class MockLocationManager: LocationManager {

  // MARK: Internal

  var requestInUseAuthorizationCallTracker = 0
  var delegate: LocationManagerDelegate?

  var authorizationStatus: CLAuthorizationStatus {
    _authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    requestInUseAuthorizationCallTracker += 1
  }

  // MARK: to mock the authorization status
  func simulateAuthorizationStatus(to status: CLAuthorizationStatus) {
    _authorizationStatus = status
    delegate?.locationManagerDidChangeAuthorization?(self)
  }

  // MARK: Private

  // MARK: Mock AuthorizationStatus field
  private var _authorizationStatus = CLAuthorizationStatus.notDetermined

}
