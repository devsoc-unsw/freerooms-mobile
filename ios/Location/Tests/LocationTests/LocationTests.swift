import CoreLocation
import Testing
@testable import Location

// MARK: - LocationServicePermissionTest

struct LocationServicePermissionTest {

  @Test("user deny access on authorize")
  func requestLocationPermissionDeniedWhenAuthorized() async throws {
    // set mock manager authorization status to be denied
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.currentPermissionState == LocationPermission.unrequested)

    // when request location denied
    let isPermissionGranted = sut.requestLocationPermissions()
    #expect(isPermissionGranted == true)
    #expect(sut.currentPermissionState == .pending)

    // mock to simulate denied permission
    mockLocationManager.simulateAuthorizationStatus(to: .denied)

    // Assert
    #expect(sut.currentPermissionState == .denied)
  }

  @Test("user grant access on authorize")
  func requestLocationPermissionGrantedWhenAuthorized() async throws {
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)

    // initial state verification
    #expect(sut.currentPermissionState == LocationPermission.unrequested)

    // when request location denied
    let isPermissionGranted = sut.requestLocationPermissions()
    #expect(isPermissionGranted == true)
    #expect(sut.currentPermissionState == .pending)

    // set mock manager authorization status to be granted
    mockLocationManager.simulateAuthorizationStatus(to: .authorizedWhenInUse)

    // Assert
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

  @Test("Test multiple permission requests")
  func multiplePermissionRequestsReturnFalse() async throws {
    let mockLocationManager = MockLocationManager()

    let sut = LocationService(locationManager: mockLocationManager)

    var isPending = sut.requestLocationPermissions()
    #expect(isPending == true)
    #expect(sut.currentPermissionState == .pending)

    isPending = sut.requestLocationPermissions()
    #expect(isPending == false)
    #expect(sut.currentPermissionState == .pending)
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
