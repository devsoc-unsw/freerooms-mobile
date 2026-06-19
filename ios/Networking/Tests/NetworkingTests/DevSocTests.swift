//
//  DevSocTests.swift
//  Networking
//
//  Created by Matthew Yuen on 3/6/2026.
//

import DevSocAPI
import Networking
import Testing

@Suite
struct DevSocTests {

  @Test
  func `Can get url for cache`() throws {
    let url = try DevSoc.onDiskCacheLocation
  }

}
