import Testing

enum DivisionError: Error {
  case divisionByZero
}

struct Divider {
  func divide(_ num1: Double, by num2: Double) throws -> Double {
    guard num2 != 0 else {
      throw DivisionError.divisionByZero
    }
    
    return num1 / num2
  }
  
  func divideResult(_ num1: Double, by num2: Double) -> DivisionResult {
    guard num2 != 0 else {
      return .failure(DivisionError.divisionByZero)
    }
    
    return .success(num1 / num2)
  }
  
  typealias DivisionResult = Result<Double, DivisionError>
}

struct UnitTests {
  /*
   MARK: Why unit test?
   - Ensure correctness of the smallest building blocks
   - Quick and relatively easy to write
   - Quick to run
   */
  
  @Test("Division by positive number returns result")
  func testPositiveDivision() {
    // Given
    let divider = Divider()
    
    // When
    let result = try! divider.divide(2, by: 4)
    
    // Then
    #expect(result == 0.5)
  }

  @Test func testNegativeDivision() {
    // Given
    let divider = Divider()
    
    // When
    let result = try! divider.divide(2, by: -4)
    
    // Then
    #expect(result == -0.5)
  }

  @Test func testDivideByZeroThrowsError() {
    // Given
    let divider = Divider()
    
    do {
      // When
      try divider.divide(2, by: 0)
      print("hello")
    } catch {
      // Then
      #expect(error as? DivisionError == DivisionError.divisionByZero)
    }
    
    // When
    let result = divider.divideResult(2, by: 0)
    
    // Then
    switch result {
    case .success(let num):
      print(num + 2)
      break
    case .failure(let error):
      #expect(error == DivisionError.divisionByZero)
      break
    }
  }

  /*
   MARK: Mocking
   - When a unit depends on other units, how can we test only the units behaviour?
   - Create fake version of real units, where we control the behaviour
   */
  
}
