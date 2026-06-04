//
//  URLSessionHTTPClientTests.swift
//  Networking
//
//  Created by Chris Wong on 26/4/2025.
//

import Foundation
import Networking
import Testing
@testable import NetworkingTestUtils

struct URLSessionHTTPClientTests {

  // MARK: Internal

  @Test("Client returns data and response on successful network request")
  func successfulConnectionAndResponse() async throws {
    // Given
    let mockURLSession = MockURLSession(data: Data(), urlResponse: HTTPURLResponse())
    let sut = URLSessionHTTPClient(session: mockURLSession)

    // When
    let res = await sut.get(from: URL(string: "www.fake.com")!)

    // Then
    expect(res, toFetch: mockURLSession.data, and: mockURLSession.urlResponse)
  }

  @Test("Client returns network failure error on network connection lost")
  func connectionLostDuringRequest() async throws {
    // Given
    let error = URLError(.networkConnectionLost)
    let mockUrlSession = MockURLSession(
      data: Data(),
      urlResponse: HTTPURLResponse(),
      error: error)
    let sut = URLSessionHTTPClient(session: mockUrlSession)

    // When
    let url = URL(string: "www.fake.com")!
    let res = await sut.get(from: url)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure(url: url, networkError: error))
  }

  @Test("Client returns invalid http error on invalid http response")
  func invalidHTTPResponse() async throws {
    // Given
    let mockUrlSession = MockURLSession(data: Data(), urlResponse: URLResponse())
    let sut = URLSessionHTTPClient(session: mockUrlSession)

    // When
    let url = URL(string: "www.fake.com")!
    let res = await sut.get(from: url)

    // Then
    expect(res, toThrow: HTTPClientError.invalidHTTPResponse(url: url))
  }

  @Test("Client returns network failure error on no internet connection")
  func noInternetConnection() async throws {
    // Given
    let error = URLError(.notConnectedToInternet)
    let mockUrlSession = MockURLSession(
      data: Data(),
      urlResponse: URLResponse(),
      error: error)
    let sut = URLSessionHTTPClient(session: mockUrlSession)

    // When
    let url = URL(string: "www.fake.com")!
    let res = await sut.get(from: url)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure(url: url, networkError: error))
  }

  @Test("Client returns network failure error when any error is thrown")
  func unknownError() async throws {
    // Given
    let error = URLError(.unknown)
    let mockUrlSession = MockURLSession(data: Data(), urlResponse: URLResponse(), error: error)
    let sut = URLSessionHTTPClient(session: mockUrlSession)

    // When
    let url = URL(string: "www.fake.com")!
    let res = await sut.get(from: url)

    // Then
    expect(res, toThrow: HTTPClientError.networkFailure(url: url, networkError: error))
  }

  // MARK: Private

  private func expect(
    _ res: HTTPClientResult,
    toThrow httpClientError: HTTPClientError,
    sourceLocation _: SourceLocation = #_sourceLocation)
  {
    switch res {
    case .failure(let error):
      #expect(error == httpClientError)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(
    _ res: HTTPClientResult,
    toFetch data: Data,
    and urlResponse: URLResponse,
    sourceLocation _: SourceLocation = #_sourceLocation)
  {
    switch res {
    case .success(let (data, httpURLResponse)):
      #expect(data == data && httpURLResponse == urlResponse)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

}
