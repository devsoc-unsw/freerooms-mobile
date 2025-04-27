//
//  URLSessionHTTPClientTests.swift
//  Networking
//
//  Created by Chris Wong on 26/4/2025.
//

import Foundation
import Networking
import Testing

struct URLSessionHTTPClientTests {

  // MARK: Internal

  /// Simulates a successful connection and response from the server
  @Test("Client returns data and response on successful network request")
  func successfulConnectionAndResponse() async throws {
    // Given
    let mockURLSession = MockURLSession(data: Data(), urlResponse: HTTPURLResponse())
    let sut = URLSessionHTTPClient(urlSession: mockURLSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toFetch: mockURLSession.data, and: mockURLSession.urlResponse)
  }

  /// Simulates connection lost during request
  @Test("Client returns network failure error on network connection lost")
  func connectionLostDuringRequest() async throws {
    // Given
    let mockUrlSession = MockURLSession(
      data: Data(),
      urlResponse: HTTPURLResponse(),
      error: URLError(.networkConnectionLost))
    let sut = URLSessionHTTPClient(urlSession: mockUrlSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure)
  }

  /// Simulates an invalid http response received
  @Test("Client returns invalid http error on invalid http response")
  func invalidHTTPResponse() async throws {
    // Given
    let mockUrlSession = MockURLSession(data: Data(), urlResponse: URLResponse())
    let sut = URLSessionHTTPClient(urlSession: mockUrlSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toThrow: HTTPClientError.invalidHTTPResponse)
  }

  /// Simulates no internet connection when making request
  @Test("Client returns network failure error on no internet connection")
  func noInternetConnection() async throws {
    // Given
    let mockUrlSession = MockURLSession(
      data: Data(),
      urlResponse: URLResponse(),
      error: URLError(.notConnectedToInternet))
    let sut = URLSessionHTTPClient(urlSession: mockUrlSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure)
  }

  /// Simulates an unknown error is thrown and caught
  @Test("Client returns network failure error when any error is thrown")
  func unknownError() async throws {
    // Given
    let mockUrlSession = MockURLSession(data: Data(), urlResponse: URLResponse(), error: URLError(.unknown))
    let sut = URLSessionHTTPClient(urlSession: mockUrlSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure)
  }

  // MARK: Private

  private func expect(_ res: HTTPClient.Result, toThrow httpClientError: HTTPClientError) {
    switch res {
    case .failure(let error):
      #expect(error as? HTTPClientError == httpClientError)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: HTTPClient.Result, toFetch data: Data, and urlResponse: URLResponse) {
    switch res {
    case .success(let (data, httpURLResponse)):
      #expect(data == data && httpURLResponse == urlResponse)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

}
