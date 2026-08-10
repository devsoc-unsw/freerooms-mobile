//
//  BookingsTabView.swift
//  Bookings
//
//  Created by Gabriella Lianti on 3/7/2026.
//

import BookingModels
import BookingViewModels
import CommonUI
import SwiftUI

// MARK: - BookingsTabView

/// Root tab for discovering bookings that overlap the current device-calendar week.
public struct BookingsTabView: View {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var body: some View {
    NavigationStack {
      content
        .navigationTitle("Bookings")
        .searchable(
          text: $searchText,
          placement: .navigationBarDrawer(displayMode: .always),
          prompt: "Search events")
    }
    .task {
      await bookingViewModel.loadCurrentWeekBookings(
        referenceDate: Date(),
        calendar: .current,
        forceRefresh: false)
    }
    .alert(item: staleDataErrorBinding) { error in
      Alert(
        title: Text(error.title),
        message: Text(error.message),
        dismissButton: .default(Text("OK")))
    }
    .sheet(item: $selectedBooking) { booking in
      BookingDetailsSheet(booking: booking)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    .tabItem {
      Label("Bookings", systemImage: "book.pages")
    }
    .tag("Bookings")
  }

  // MARK: Private

  @Environment(LiveBookingViewModel.self) private var bookingViewModel

  @State private var selectedBooking: WeeklyBooking?
  @State private var searchText = ""

  private var filteredBookings: [WeeklyBooking] {
    BookingSearch.filter(bookingViewModel.bookings, query: searchText)
  }

  private var staleDataErrorBinding: Binding<BookingPresentationError?> {
    Binding(
      get: {
        bookingViewModel.bookings.isEmpty ? nil : bookingViewModel.errorMessage
      },
      set: { bookingViewModel.errorMessage = $0 })
  }

  @ViewBuilder
  private var content: some View {
    if bookingViewModel.isLoading, bookingViewModel.bookings.isEmpty {
      ProgressView("Loading this week's bookings…")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else if let error = bookingViewModel.errorMessage, bookingViewModel.bookings.isEmpty {
      ContentUnavailableView {
        Label("Couldn't Load Bookings", systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
      } description: {
        Text(error.message)
      } actions: {
        Button("Try Again") {
          Task {
            await refresh()
          }
        }
        .buttonStyle(.borderedProminent)
        .accessibilityHint("Attempts to load this week's bookings again")
      }
    } else if bookingViewModel.bookings.isEmpty {
      ContentUnavailableView(
        "No Bookings This Week",
        systemImage: "calendar.badge.checkmark",
        description: Text("There are no room bookings to show for the current week."))
    } else if filteredBookings.isEmpty {
      ContentUnavailableView.search(text: searchText)
    } else {
      BookingsListView(
        bookings: filteredBookings,
        isLoading: bookingViewModel.isLoading,
        selectedBooking: $selectedBooking,
        onRefresh: refresh)
    }
  }

  private func refresh() async {
    await bookingViewModel.loadCurrentWeekBookings(
      referenceDate: Date(),
      calendar: .current,
      forceRefresh: true)
  }
}

#Preview {
  BookingsTabView()
    .defaultTheme()
    .environment(PreviewBookingViewModel() as LiveBookingViewModel)
}
