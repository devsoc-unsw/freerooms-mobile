//
//  MockApolloDataSource.swift
//  TestingSupport
//
//  Created by Matthew Yuen on 5/6/2026.
//

import Apollo
import DevSocAPI
import Foundation

final public actor MockApolloDataSource {

  // MARK: Lifecycle

  public init(
    endpoint: URL = defaultEndpoint)
  {
    let session = MockApolloURLSession(clearOnRequest: false)

    let store = ApolloStore()

    let transport = RequestChainNetworkTransport(
      urlSession: session,
      interceptorProvider: DefaultInterceptorProvider.shared,
      store: store,
      endpointURL: endpoint)

    let client = ApolloClient(
      networkTransport: transport,
      store: store)

    self.endpoint = endpoint
    self.session = session
    self.store = store
    self.client = client
  }

  // MARK: Public

  public static let defaultEndpoint = URL(string: "https://api.mockapollo.com/graphql")!

  /// The client
  ///
  /// The client is configured to make requests to the data source
  nonisolated public let client: ApolloClient
  nonisolated public let endpoint: URL

  /// The mock session
  nonisolated public let session: MockApolloURLSession
  nonisolated public let store: ApolloStore

}
