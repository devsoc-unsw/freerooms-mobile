//
//  RoomBookingInformationView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import SwiftUI
import CommonUI
import RoomModels

struct RoomBookingInformationView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Title
      HStack {
        Text(room.name)
          .font(.title)
          .bold()
          .foregroundStyle(theme.label.primary)
        
        Spacer()
        
        HStack(alignment: .center, spacing: 2) {
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
            .padding(0)
          
          Text("\(String(describing: room.overallRating))")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .overlay(
          Capsule()
            .stroke(.gray.tertiary, lineWidth: 1)
            .backgroundStyle(.gray))
        .background(.gray.quinary, in: Capsule())
      }
      
      VStack(spacing: 12) {
        if room.school.trimmingCharacters(in: .whitespaces) == "" {
          EmptyView()
        } else {
          Text("School of \(room.school)")
            .fontWeight(.bold)
            .font(.title3)
            .foregroundStyle(theme.label.primary)
        }
        // Info
        HStack {
          RoomLabel(leftLabel: "ID", rightLabel: room.id)
          Spacer()
          RoomLabel(leftLabel: "Abbreviation", rightLabel: room.abbreviation)
        }
      }
      .padding(.vertical, 12)
    }
    
  }
  var room: Room
  @Environment(Theme.self) private var theme
}

#Preview {
  RoomBookingInformationView(room: Room.exampleOne)
    .defaultTheme()
}
