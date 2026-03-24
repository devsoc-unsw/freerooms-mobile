//
//  RatingBar.swift
//  Rooms
//

import CommonUI
import SwiftUI

struct RatingBar: View {

  // MARK: Internal

  let label: String
  let icon: String
  let value: Double

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Image(systemName: icon)
          .foregroundStyle(.secondary)
          .frame(width: 20)

        Text(label)
          .font(.subheadline)

        Spacer()

        Text("\(value, specifier: "%.1f")")
          .font(.subheadline)
          .bold()
          .monospacedDigit()
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.15))

          RoundedRectangle(cornerRadius: 6)
            .fill(
              LinearGradient(
                colors: [theme.accent.secondary, theme.accent.primary],
                startPoint: .leading,
                endPoint: .trailing))
            .frame(width: geo.size.width * min(value / 5.0, 1.0))
        }
      }
      .frame(height: 10)
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

#Preview {
  VStack(spacing: 16) {
    RatingBar(label: "Cleanliness", icon: "sparkles", value: 4.5)
    RatingBar(label: "Location", icon: "mappin.and.ellipse", value: 3.2)
    RatingBar(label: "Quietness", icon: "speaker.slash.fill", value: 5.0)
  }
  .padding()
  .defaultTheme()
}
