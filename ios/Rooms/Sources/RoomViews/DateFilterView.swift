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
    selectedDate: Binding<Date?>,
    selectedStartTime: Binding<Date?>,
    onSelect: @escaping () -> Void)
  {
    _selectedDate = selectedDate
    _selectedStartTime = selectedStartTime
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 0) {
      // Drag handle
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 36, height: 4)
        .padding(.top, 12)
        .padding(.bottom, 16)

      // Title
      Text("Date")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)

      // Calendar
      VStack(spacing: 16) {
        // Month and navigation
        HStack {
          Text(monthYearFormatter.string(from: currentMonth))
            .font(.headline)
            .fontWeight(.semibold)

          Spacer()

          HStack(spacing: 20) {
            Button(action: previousMonth) {
              Image(systemName: "chevron.left")
                .foregroundColor(.blue)
                .font(.title3)
            }

            Button(action: nextMonth) {
              Image(systemName: "chevron.right")
                .foregroundColor(.blue)
                .font(.title3)
            }
          }
        }
        .padding(.horizontal, 20)

        // Calendar grid
        calendarGridView
          .padding(.horizontal, 20)

        // Divider
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .frame(height: 1)
          .padding(.horizontal, 20)
          .padding(.vertical, 16)

        // Time selection
        HStack {
          Text("Start")
            .font(.body)

          Spacer()

          Button(action: showTimePicker) {
            Text(timeFormatter.string(from: selectedStartTime ?? defaultStartTime))
              .foregroundColor(.primary)
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(Color.gray.opacity(0.1))
              .cornerRadius(8)
          }
        }
        .padding(.horizontal, 20)
      }

      // Spacing
      Spacer()
        .frame(height: 20)

      // Select button
      Button(action: onSelect) {
        Text("Select")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.orange)
          .cornerRadius(12)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .background(Color.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
    .sheet(isPresented: $showingTimePicker) {
      timePickerSheet
    }
  }

  // MARK: Private

  @Binding private var selectedDate: Date?
  @Binding private var selectedStartTime: Date?
  @State private var currentMonth = Date()
  @State private var showingTimePicker = false

  private let onSelect: () -> Void

  private let defaultStartTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()

  private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
  }

  private var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter
  }

  private var calendarGridView: some View {
    VStack(spacing: 8) {
      // Days of week header
      HStack {
        ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
          Text(day)
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
        }
      }

      // Calendar days
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
        ForEach(daysInMonth, id: \.self) { day in
          if let day {
            Button(action: { selectDate(day) }) {
              Text("\(day)")
                .font(.body)
                .foregroundColor(dayColor(for: day))
                .frame(width: 32, height: 32)
                .background(dayBackground(for: day))
                .clipShape(Circle())
            }
          } else {
            Text("")
              .frame(width: 32, height: 32)
          }
        }
      }
    }
  }

  private var timePickerSheet: some View {
    NavigationView {
      VStack {
        DatePicker(
          "Start Time",
          selection: Binding(
            get: { selectedStartTime ?? defaultStartTime },
            set: { selectedStartTime = $0 }),
          displayedComponents: .hourAndMinute)
          .datePickerStyle(.wheel)
          .padding()

        Spacer()
      }
      .navigationTitle("Start Time")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            showingTimePicker = false
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            showingTimePicker = false
          }
        }
      }
    }
  }

  private var daysInMonth: [Int?] {
    let calendar = Calendar.current
    let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
    let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<32
    let firstWeekday = calendar.component(.weekday, from: startOfMonth)

    var days: [Int?] = []

    // Add empty cells for days before the first day of the month
    for _ in 1..<firstWeekday {
      days.append(nil)
    }

    // Add days of the month
    for day in range {
      days.append(day)
    }

    return days
  }

  private func previousMonth() {
    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
  }

  private func nextMonth() {
    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
  }

  private func selectDate(_ day: Int) {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: currentMonth)
    if let date = calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) {
      selectedDate = date
    }
  }

  private func dayColor(for day: Int) -> Color {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: currentMonth)
    guard let date = calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) else {
      return .primary
    }

    if let selectedDate, calendar.isDate(date, inSameDayAs: selectedDate) {
      return .white
    } else if calendar.isDateInToday(date) {
      return .blue
    } else {
      return .primary
    }
  }

  private func dayBackground(for day: Int) -> Color {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: currentMonth)
    guard let date = calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) else {
      return .clear
    }

    if let selectedDate, calendar.isDate(date, inSameDayAs: selectedDate) {
      return .blue
    } else {
      return .clear
    }
  }

  private func showTimePicker() {
    showingTimePicker = true
  }
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
    selectedDate: .constant(nil),
    selectedStartTime: .constant(nil))
  {
    // onSelect action
  }
}
