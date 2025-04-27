import CoreLocation
import Testing
@testable import Location

// MARK: - LocationServicePermissionTest

struct LocationServicePermissionTest {

  @Test("user deny access on authorize")
  func requestLocationPermissionDeniedWhenAuthorized() async throws {
    // set mock manager authorization status to be denied
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .denied)

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.currentPermissionState == LocationPermission.unrequested)

    // when request location denied
    let isPermissionGranted = sut.requestLocationPermissions()

    // Assert
    #expect(isPermissionGranted == false)
    #expect(sut.currentPermissionState == .denied)
  }

  @Test("user grant access on authorize")
  func requestLocationPermissionGrantedWhenAuthorized() async throws {
    // set mock manager authorization status to be granted
    let mockLocationManager = MockLocationManager()
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.currentPermissionState == LocationPermission.unrequested)

    // when request location denied
    let isPermissionGranted = sut.requestLocationPermissions()

    // Assert
    #expect(isPermissionGranted == true)
    #expect(sut.currentPermissionState == .granted)
  }

  @Test("location service should be unrequested on startup")
  func locationPermissionUnrequestedOnStartup() async throws {
    // mock setup
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)
    let sutCurrentPermission = sut.currentPermissionState

    #expect(sutCurrentPermission == .unrequested)
  }

}

// MARK: - MockLocationManager

class MockLocationManager: LocationManager {

  // MARK: Internal

  var requestInUseAuthorizationCallTracker = 0
  var delegate: CLLocationManagerDelegate?

  var authorizationStatus: CLAuthorizationStatus {
    _authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    requestInUseAuthorizationCallTracker += 1
  }

  // MARK: to mock the authorization status
  func simulateAuthorizationStatus(to status: CLAuthorizationStatus) {
    _authorizationStatus = status
  }

  // MARK: Private

  // MARK: Mock AuthorizationStatus field
  private var _authorizationStatus = CLAuthorizationStatus.notDetermined

}
