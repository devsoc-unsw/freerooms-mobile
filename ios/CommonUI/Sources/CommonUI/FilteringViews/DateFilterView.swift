//
//  DateFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

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
    VStack(spacing: 20) {
      // Title
      Text("Date")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)

      // Calendar
      DatePicker(
          "Select a date",
          selection: $selectedDate,
          displayedComponents: .date
      )
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

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
  }

  // MARK: Private
  @Binding private var selectedDate: Date
  @State private var currentMonth = Date()
  @State private var showingTimePicker = false
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
  DateFilterView(
    selectedDate: .constant(Date()))
  {
    // onSelect action
  }
  .defaultTheme()
}
