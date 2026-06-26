//
//  DateFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomViewModels
import SwiftUI

// MARK: - DateFilterView

public struct DateFilterView: View {

  // MARK: Lifecycle

  public init(
    selectedDate: Binding<Date>,
    onSelect: @escaping () -> Void)
  {
    _selectedDate = selectedDate
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 15) {
      // Title
      Text("Date")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Calendar
      DatePicker(
        "Select a date",
        selection: $selectedDate,
        displayedComponents: .date)
        .datePickerStyle(.graphical)
        .tint(theme.accent.primary)

      // Divider
      Rectangle()
        .fill(Color.gray.opacity(0.3))
        .frame(height: 2)

      // Time selection
      HStack {
        Text("Start")
          .font(.headline)
          .bold()

        Spacer()

        DatePicker("Please enter a time", selection: $selectedDate, displayedComponents: .hourAndMinute)
          .labelsHidden()
      }

      ClearButton(filterName: "Date & Time", clearFilter: roomViewModel.clearDateFilter, onSelect: onSelect)

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
  }

  // MARK: Private

  @Binding private var selectedDate: Date
  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme

  private let onSelect: () -> Void
}

// MARK: - View Extensions

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

// MARK: - RoundedCorner

struct RoundedCorner: Shape {
  var radius = CGFloat.infinity
  var corners = UIRectCorner.allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

// MARK: - Preview

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return DateFilterView(selectedDate: .constant(Date()), onSelect: { })
    .defaultTheme()
    .environment(viewModel)
}
