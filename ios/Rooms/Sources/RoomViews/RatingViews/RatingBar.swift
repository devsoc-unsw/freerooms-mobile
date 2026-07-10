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
    VStack(spacing: Self.contentSpacing) {
      HStack {
        Image(systemName: icon)
          .foregroundStyle(.secondary)
          .frame(width: Self.iconColumnWidth)

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
          RoundedRectangle(cornerRadius: Self.barCornerRadius)
            .fill(Color.gray.opacity(Self.trackOpacity))

          RoundedRectangle(cornerRadius: Self.barCornerRadius)
            .fill(
              LinearGradient(
                colors: [theme.accent.secondary, theme.accent.primary],
                startPoint: .leading,
                endPoint: .trailing))
            .frame(width: geo.size.width * min(value / Self.maximumRatingValue, Self.fullProgress))
        }
      }
      .frame(height: Self.barHeight)
    }
  }

  // MARK: Private

  private static let barCornerRadius: CGFloat = 6
  private static let barHeight: CGFloat = 10
  private static let contentSpacing: CGFloat = 6
  private static let fullProgress = 1.0
  private static let iconColumnWidth: CGFloat = 20
  private static let maximumRatingValue = 5.0
  private static let trackOpacity = 0.15

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
