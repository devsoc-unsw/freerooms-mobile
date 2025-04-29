import CoreLocation
import Testing
@testable import Location

// MARK: - LocationServicePermissionTest

struct LocationServicePermissionTest {

  @Test("userAuthorizationStatus denied on initiliaze")
  func requestLocationPermissionDeniedOnInitialize() async throws {
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .denied)

    // when UserAuthorizationStatus not denied on initialise
    let sut = LocationService(locationManager: mockLocationManager)
    #expect(sut.currentPermissionState == .denied)
  }

  @Test("userAuthorizationStatus unrequested on initialize")
  func requestLocationPermissionUnrequestedOnInitialize() async throws {
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    // when UserAuthorizationStatus not determied on initialise
    let sut = LocationService(locationManager: mockLocationManager)
    #expect(sut.currentPermissionState == .unrequested)
  }

  @Test("userAuthorizationStatus granted on initialize")
  func requestLocationPermissionGrantedOnInitialize() async throws {
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    // when UserAuthorizationStatus granted on initialise
    let sut = LocationService(locationManager: mockLocationManager)
    #expect(sut.currentPermissionState == .granted)
  }

  @Test("user request permission on pending permissionState")
  func requestLocationPermissionOnPendingState() async throws {
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    let sut = LocationService(locationManager: mockLocationManager)

    // request user location permission
    #expect(throws: Never.self) {
      let hasPermissionBeenGranted = try sut.requestLocationPermissions()

      #expect(hasPermissionBeenGranted == true)
      #expect(sut.currentPermissionState == .pending)
    }

    #expect(throws: Never.self) {
      // request user location permission again
      let hasPermissionBeenGranted = try sut.requestLocationPermissions()

      // expect early false return
      #expect(hasPermissionBeenGranted == false)
      #expect(sut.currentPermissionState == .pending)
    }
  }

  @Test("user deny access on authorize")
  func requestLocationPermissionDeniedWhenAuthorized() async throws {
    // set mock manager authorization status to be denied
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .notDetermined)

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.locationManager.authorizationStatus == .notDetermined)

    // when request location denied
    #expect(throws: Never.self) {
      let hasPermissionBeenGranted = try sut.requestLocationPermissions()
      #expect(hasPermissionBeenGranted == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // mock to simulate denied permission
    mockLocationManager.simulateAuthorizationStatus(to: .denied)

    // Assert
    #expect(throws: LocationServiceError.locationPermissionsDenied) {
      try sut.requestLocationPermissions()
    }
  }

  @Test("user grant access on authorize")
  func requestLocationPermissionGrantedWhenAuthorized() async throws {
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.currentPermissionState == LocationPermission.unrequested)

    // when request location denied
    #expect(throws: Never.self) {
      let hasPermissionBeenGranted = try sut.requestLocationPermissions()
      #expect(hasPermissionBeenGranted == true)
      #expect(sut.currentPermissionState == .pending)
    }

    // set mock manager authorization status to be granted
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    // Assert
    #expect(sut.currentPermissionState == .granted)
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
