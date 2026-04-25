//
//  HTTPResponseFactory.swift
//  Networking
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation

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
