//
//  MapSearchBarView.swift
//  Buildings
//
//  Created by Dicko Evaldo on 27/9/2025.
//

import SwiftUI

struct MapSearchBar: View {

  // MARK: Internal

  @Binding var searchtxt: String

  var body: some View {
    HStack {
      HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search", text: $searchtxt)
          .focused($isSearchFocused) // Track focus state
          .padding(.horizontal, 10)
          .padding(.vertical, 8)
      }
      .padding(.horizontal)
      .background(Color(.secondarySystemBackground))
      .cornerRadius(10)
      .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

      if isSearchFocused {
        Button("Cancel") {
          searchtxt = ""
          withAnimation(.spring()) {
            isSearchFocused = false
          }
        }
        .transition(.move(edge: .trailing)) // Add animation for cancel button
      }
    }
    .padding(.horizontal)
  }

  // MARK: Private

  @FocusState private var isSearchFocused: Bool // Track focus state
}
