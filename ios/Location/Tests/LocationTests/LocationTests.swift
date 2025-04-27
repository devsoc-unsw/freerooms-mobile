import Testing
import CoreLocation
@testable import Location

@Test
func request_location_permission_denial() async throws {
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test
func request_location_permission_granted() async throws {
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}


// MARK: - LocationManager Protocol

protocol LocationManager {
  // MARK: Internal
  var delegate: CLLocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }
  
  func requestWhenInUseAuthorization()
}

// MARK: - MockLocationManager

class MockLocationManager: LocationManager {
  var requestInUseAuthorizationCallTracker = 0;
  var delegate: CLLocationManagerDelegate?
  
  // MARK: Mock AuthorizationStatus field
  private var _authorizationStatus =  CLAuthorizationStatus.notDetermined
  var authorizationStatus: CLAuthorizationStatus {
    return _authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    requestInUseAuthorizationCallTracker += 1
  }
  
  // MARK: to mock the authorization status
  func simulateAuthorizationStatus(to status: CLAuthorizationStatus) {
    _authorizationStatus = status
  }
  
}
