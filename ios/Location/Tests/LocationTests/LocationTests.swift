import CoreLocation
import Testing
@testable import Location

@Test
func request_location_permission_denial() async throws {
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test
func request_location_permission_granted() async throws {
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

// MARK: - LocationManager

protocol LocationManager {
  // MARK: Internal
  var delegate: CLLocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }

  func requestWhenInUseAuthorization()
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
