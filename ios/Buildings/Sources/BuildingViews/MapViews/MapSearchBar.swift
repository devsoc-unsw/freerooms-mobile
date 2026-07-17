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
          .focused($isSearchFocused)
          .padding(.horizontal, Self.textFieldHorizontalPadding)
          .padding(.vertical, Self.textFieldVerticalPadding)
      }
      .padding(.horizontal)
      .background(Color(.secondarySystemBackground))
      .clipShape(.capsule)

      if isSearchFocused {
        Button("Cancel") {
          searchtxt = ""
          isSearchFocused = false
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
      }
    }
    .padding(.horizontal)
    .animation(.spring(), value: isSearchFocused)
  }

  // MARK: Private

  private static let textFieldHorizontalPadding: CGFloat = 10
  private static let textFieldVerticalPadding: CGFloat = 8

  @FocusState private var isSearchFocused: Bool

}

#Preview {
  @Previewable
  @State var searchtxt = ""
  MapSearchBar(searchtxt: $searchtxt)
}
