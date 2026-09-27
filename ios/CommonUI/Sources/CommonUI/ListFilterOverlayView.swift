//
//  ListFilterOverlayView.swift
//  CommonUI
//
//  Created by Matthew Yuen on 26/9/2026.
//

public import SwiftUI

// MARK: - ListFilterOverlayViewOption

public protocol ListFilterOverlayViewOption: CaseIterable, Hashable where Self.AllCases: RandomAccessCollection<Self> {
  var title: String { get }
  var systemImage: String { get }
}

// MARK: - ListFilterOverlayView

public struct ListFilterOverlayView<Option: ListFilterOverlayViewOption>: View {

  // MARK: Lifecycle

  public init(
    for _: Option.Type = Option.self,
    isPresented: Binding<Bool>,
    onSelection: @escaping (_ option: Option) -> Void,
    onClear: @escaping () -> Void)
  {
    _isPresented = isPresented
    self.onSelection = onSelection
    self.onClear = onClear
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .trailing, spacing: menuSpacing) {
      // Menu Items
      if isPresented {
        ForEach(Option.allCases, id: \.self) { option in
          filterMenuAction(option.title, systemImage: option.systemImage) {
            onSelection(option)
          }
        }

        filterMenuAction("Delete All", systemImage: "xmark", role: .destructive, action: onClear)
      }

      // Toggle Button
      Button(action: buttonAction) {
        Image(systemName: buttonImageSystemName)
          .font(.title2)
          .foregroundStyle(theme.accent.primary)
          .padding()
          .frame(width: toggleButtonSize, height: toggleButtonSize)
          .background {
            Circle()
              .fill(theme.background.secondary)
              .overlay {
                Circle()
                  .stroke(theme.accent.primary.opacity(toggleBorderOpacity), lineWidth: toggleBorderWidth)
              }
              .shadow(
                color: .black.opacity(toggleShadowOpacity),
                radius: toggleShadowRadius,
                y: toggleShadowYOffset)
          }
      }
    }
  }

  // MARK: Private

  @Binding private var isPresented: Bool
  @Environment(Theme.self) private var theme

  private let onSelection: (Option) -> Void
  private let onClear: () -> Void

  private var buttonImageSystemName: String {
    if isPresented {
      "line.3.horizontal.decrease"
    } else {
      "xmark"
    }
  }

  private var actionBorderColor: Color {
    theme.accent.primary.opacity(actionBorderOpacity)
  }

  private func buttonAction() {
    withAnimation(.spring) {
      isPresented.toggle()
    }
  }

  @ViewBuilder
  private func filterMenuAction(
    _ title: String,
    systemImage: String,
    role: ButtonRole? = nil,
    action: @escaping () -> Void)
    -> some View
  {
    Button {
      action()
    } label: {
      Label(title, systemImage: systemImage)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(role == .destructive ? theme.list.red : theme.accent.primary)
        .padding(.horizontal, actionHorizontalPadding)
        .padding(.vertical, actionVerticalPadding)
        .background {
          Capsule()
            .fill(theme.background.secondary)
            .overlay {
              Capsule()
                .stroke(
                  role == .destructive ? theme.list.red.opacity(destructiveBorderOpacity) : actionBorderColor,
                  lineWidth: actionBorderWidth)
            }
            .shadow(
              color: .black.opacity(actionShadowOpacity),
              radius: actionShadowRadius,
              y: actionShadowYOffset)
        }
    }
    .buttonStyle(.plain)
  }

}

// MARK: - Configuration

private let menuSpacing: CGFloat = 10
private let actionHorizontalPadding: CGFloat = 12
private let actionBorderOpacity = 0.28
private let actionBorderWidth: CGFloat = 1
private let actionVerticalPadding: CGFloat = 10
private let actionShadowOpacity = 0.32
private let actionShadowRadius: CGFloat = 12
private let actionShadowYOffset: CGFloat = 4
private let destructiveBorderOpacity = 0.36
private let toggleBorderOpacity = 0.24
private let toggleBorderWidth: CGFloat = 1
private let toggleButtonSize: CGFloat = 56
private let toggleShadowOpacity = 0.34
private let toggleShadowRadius: CGFloat = 14
private let toggleShadowYOffset: CGFloat = 5

#if DEBUG
private enum _PreviewOption: ListFilterOverlayViewOption {
  case foo
  case bar

  // MARK: Internal

  var title: String {
    switch self {
    case .foo:
      "Foo"
    case .bar:
      "Bar"
    }
  }

  var systemImage: String {
    switch self {
    case .foo:
      "star.fill"
    case .bar:
      "square.and.arrow.up"
    }
  }
}

#Preview {
  @Previewable @State var isPresented = false
  ListFilterOverlayView(for: _PreviewOption.self, isPresented: $isPresented) {
    print("selected: \($0)")
  } onClear: {
    print("cleared")
  }
  .defaultTheme()
}
#endif
