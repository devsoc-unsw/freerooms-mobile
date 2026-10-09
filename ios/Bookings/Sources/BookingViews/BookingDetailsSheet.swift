//
//  BookingDetailsSheet.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import CommonUI
import SwiftUI

// MARK: - BookingDetailsSheet

struct BookingDetailsSheet: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: BookingViewLayout.detailsSectionSpacing) {
          BookingHeader(booking: booking)
          Divider()
          BookingInformation(booking: booking)
          Divider()
          BookingFacilities(booking: booking)
        }
        .padding(BookingViewLayout.detailsPadding)
      }
      .background(theme.background.primary)
      .navigationTitle("Booking Details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
          .accessibilityHint("Closes booking details")
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(Theme.self) private var theme
}

#Preview {
  BookingDetailsSheet(
    booking: WeeklyBooking(
      title: "DevSoc Weekly Meeting",
      bookingType: "BLOCK",
      roomID: "K-H6-LG03",
      roomName: "Tyree Energy Technology LG03",
      buildingID: "K-H6",
      buildingName: "Tyree Energy Technologies Building",
      start: Date(timeIntervalSince1970: 1_798_128_000),
      end: Date(timeIntervalSince1970: 1_798_195_200),
      usage: "TUSM",
      capacity: 50,
      abbreviation: "TETBLG03",
      accessibility: [
        "Ventilation - Air conditioning",
        "Weekend Access",
        "Wheelchair access - teaching",
        "Wheelchair access - student",
        "Power at Wall",
      ],
      audioVisual: [
        "Document camera",
      ],
      infoTechnology: [
        "Hybrid Teaching Space",
        "Lecture capture venue",
        "Lecture capture with video feed",
        "Interactive Learning Space (High Tech)",
        "IT laptop connection",
        "IT Lectern",
        "Video data projector",
      ],
      microphone: [
        "Dual Radio Microphones",
        "Lectern (fixed)",
        "Radio microphone",
      ],
      service: [],
      writingMedia: [
        "Blackboard",
        "Whiteboard",
      ]))
      .defaultTheme()
}
