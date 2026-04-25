//
//  HTTPResponseFactory.swift
//  Networking
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation

/// A helper function to create a mock HTTP response for testing purposes
///
/// - Parameters:
///  - route: The API route for which the response is being created (e.g., "/api/rooms/search")
///  - json: The JSON string representing the response body
///  - statusCode: The HTTP status code for the response (default is 200)
///
/// - Returns: A tuple containing the response data and an HTTPURLResponse object
func makeHTTPResponse(
  route: String,
  json: String,
  statusCode: Int = 200)
  -> (Data, HTTPURLResponse)
{
  let url = URL(string: "https://freerooms.devsoc.app\(route)")!

  let response = HTTPURLResponse(
    url: url,
    statusCode: statusCode,
    httpVersion: nil,
    headerFields: nil)!

  return (Data(json.utf8), response)
}
