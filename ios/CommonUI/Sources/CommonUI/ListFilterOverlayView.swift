//
//  ListFilterOverlayView.swift
//  CommonUI
//
//  Created by Matthew Yuen on 26/9/2026.
//

public import SwiftUI

public protocol ListFilterOverlayViewOption: CaseIterable, Hashable where Self.AllCases: RandomAccessCollection<Self> {
  var title: String { get }
  var systemImage: String { get }
}

public struct ListFilterOverlayView<Option: ListFilterOverlayViewOption>: View {
  @Binding private var selection: Option?
  @Binding private var isPresented: Bool
  
  public init(selection: Binding<Option?>, isPresented: Binding<Bool>) {
    _selection = selection
    _isPresented = isPresented
  }
  
  @Environment(Theme.self) private var theme
  
  public var body: some View {
    VStack(alignment: .trailing, spacing: menuSpacing) {
      
      // Menu Items
      if isPresented {
        ForEach(Option.allCases, id: \.self) { option in
          filterMenuAction(option.title, systemImage: option.systemImage) {
            selection = option
          }
        }
        
        filterMenuAction("Delete All", systemImage: "xmark", role: .destructive) {
          selection = nil
        }
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
  
  private func buttonAction() {
    withAnimation(.spring) {
      isPresented.toggle()
    }
  }
  
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
private let animationDuration = 0.25
private let destructiveBorderOpacity = 0.36
private let toggleBorderOpacity = 0.24
private let toggleBorderWidth: CGFloat = 1
private let toggleButtonSize: CGFloat = 56
private let toggleIconSize: CGFloat = 20
private let toggleShadowOpacity = 0.34
private let toggleShadowRadius: CGFloat = 14
private let toggleShadowYOffset: CGFloat = 5

#if DEBUG
private enum _PreviewOption: ListFilterOverlayViewOption {
  case foo
  case bar
  
  var title: String {
    switch self {
    case .foo:
      return "Foo"
    case .bar:
      return "Bar"
    }
  }
  
  var systemImage: String {
    switch self {
    case .foo:
      return "star.fill"
    case .bar:
      return "square.and.arrow.up"
    }
  }
}

#Preview {
  @Previewable @State var selection: _PreviewOption?
  @Previewable @State var isPresented: Bool = false
  ListFilterOverlayView(selection: $selection, isPresented: $isPresented)
    .defaultTheme()
}
#endif

