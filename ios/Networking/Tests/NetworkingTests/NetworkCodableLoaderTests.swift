//
//  NetworkCodableLoaderTests.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Foundation
import Networking
import Testing
import TestingSupport

// MARK: - NetworkCodableLoaderTests

final class NetworkCodableLoaderTests {

  // MARK: Lifecycle

  deinit {
    clientTracker?.verifyDeallocation()
    sutTracker?.verifyDeallocation()
  }

  // MARK: Internal

  typealias SUT = NetworkCodableLoader<String>

  /// Ensures that no network calls are made when a `NetworkCodableLoader` is first created.
  @Test("Initialised loader does not request data")
  func initialisedNetworkCodableLoaderDoesntRequestData() async {
    let (client, _) = makeSut()

    #expect(client.networkCallCount == 0)
  }

  /// Simulates a network failure from the HttpClient and verifies that the loader returns a connectivity error.
  @Test("Loader throws error on network failure")
  func networkCodableLoaderThrowsErrorOnNetworkFailure() async {
    let (client, sut) = makeSut()
    client.setNextRequestToFailWithClientError()

    await expect(sut, toThrow: SUT.Error.connectivity)
    #expect(client.networkCallCount == 1)
  }

  /// Tests if the loader correctly handles unexpected or malformed data.
  @Test("Loader throws error on invalid data returned from network")
  func networkCodableLoaderThrowsErrorOnInvalidData() async {
    let (client, sut) = makeSut()
    client.setNextRequestToSucceedWithReturnedData(try? JSONEncoder().encode(1))

    await expect(sut, toThrow: SUT.Error.invalidData)
    #expect(client.networkCallCount == 1)
  }

  /// Ensures that HTTP status codes outside `200` (e.g., 199, 201, 300, 400, 500) trigger an error.
  @Test("Loader throws error on non 200 HTTP response", arguments: [199, 201, 300, 400, 500])
  func networkCodableLoaderThrowsErrorOnNon200HTTPResponse(statusCode code: Int) async {
    let (client, sut) = makeSut()
    client.setNextRequestToSucceedWithStatusCode(code)

    await expect(sut, toThrow: SUT.Error.invalidData)
    #expect(client.networkCallCount == 1)
  }

  /// Ensures that an empty response from the API correctly results in an empty string.
  @Test("Loader returns empty string")
  func networkCodableLoaderReturnsEmptyString() async {
    let (client, sut) = makeSut()
    client.setNextRequestToSucceedWithReturnedData("".data)

    await expect(sut, toFetch: "")
    #expect(client.networkCallCount == 1)
  }

  /// Verifies that valid string data is correctly returned and decoded from the API.
  @Test("Loader returns non-empty string")
  func networkCodableLoaderReturnsNonEmptyString() async {
    let (client, sut) = makeSut()
    let expectedString = makeUniqueString()
    client.setNextRequestToSucceedWithReturnedData(expectedString.data)

    await expect(sut, toFetch: expectedString)
    #expect(client.networkCallCount == 1)
  }

  /// Ensures that consecutive fetch requests return updated results instead of cached data.
  @Test("Loader fetch requests return different lists of buildings")
  func networkCodableLoaderFetchRequestDoesNotCache() async {
    let (client, sut) = makeSut()
    var expectedString = makeUniqueString()
    client.setNextRequestToSucceedWithReturnedData(expectedString.data)

    await expect(sut, toFetch: expectedString)
    #expect(client.networkCallCount == 1)

    expectedString = makeUniqueString()
    client.setNextRequestToSucceedWithReturnedData(expectedString.data)

    await expect(sut, toFetch: expectedString)
    #expect(client.networkCallCount == 2)
  }

  // MARK: Private

  private var clientTracker: MemoryLeakTracker<MockHTTPClient>?
  private var sutTracker: MemoryLeakTracker<SUT>?

  private func makeSut(sourceLocation: SourceLocation = #_sourceLocation) -> (client: MockHTTPClient, sut: SUT) {
    let client = MockHTTPClient()
    let sut = NetworkCodableLoader<String>(client: client, url: URL(string: "https://a-url.com")!)
    clientTracker = MemoryLeakTracker(instance: client, sourceLocation: sourceLocation)
    sutTracker = MemoryLeakTracker(instance: sut, sourceLocation: sourceLocation)
    return (client, sut)
  }

  private func makeUniqueString() -> String {
    UUID().uuidString
  }

  private func expect(_ sut: SUT, toThrow error: SUT.Error, sourceLocation: SourceLocation = #_sourceLocation) async {
    switch await sut.fetch() {
    case .success(let response):
      Issue.record("Expected an error but got \(response)", sourceLocation: sourceLocation)
    case .failure(let receivedError):
      #expect(receivedError as? SUT.Error == error, sourceLocation: sourceLocation)
    }
  }

  private func expect(_ sut: SUT, toFetch string: String, sourceLocation: SourceLocation = #_sourceLocation) async {
    var receivedString: String?

    switch await sut.fetch() {
    case .success(let fetchedString):
      receivedString = fetchedString
    case .failure(let error):
      Issue.record("Expected \(string) but got \(error)", sourceLocation: sourceLocation)
    }

    #expect(receivedString == string, sourceLocation: sourceLocation)
  }
}

// MARK: - MockHTTPClient

/// Simulates network responses.
private class MockHTTPClient: HTTPClient {

  // MARK: Public

  public enum Error: Swift.Error {
    case networkFailure
  }

  // MARK: Internal

  var networkCallCount = 0
  var returnedStringData: Data?
  // swiftlint:disable:next implicitly_unwrapped_optional
  var returnedStatusCode: Int!

  func setNextRequestToFailWithClientError() {
    returnedStringData = nil
  }

  func setNextRequestToSucceedWithStatusCode(_ statusCode: Int) {
    returnedStringData = "".data
    returnedStatusCode = statusCode
  }

  func setNextRequestToSucceedWithReturnedData(_ data: Data?) {
    returnedStringData = data
    returnedStatusCode = 200
  }

  func get(from url: URL) async -> HTTPClient.Result {
    networkCallCount += 1

    if let returnedStringData {
      return Result.success((
        returnedStringData,
        HTTPURLResponse(url: url, statusCode: returnedStatusCode, httpVersion: nil, headerFields: nil)!))
    } else {
      return .failure(Error.networkFailure)
    }
  }
}

extension String {
  fileprivate var data: Data {
    (try? JSONEncoder().encode(self)) ?? Data()
  }
}
