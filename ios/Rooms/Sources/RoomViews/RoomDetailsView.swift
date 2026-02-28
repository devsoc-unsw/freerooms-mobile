//
//  RoomDetailsView.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomDetailsView

public struct RoomDetailsView: View {

  // MARK: Lifecycle

  public init(room: Room, roomViewModel: RoomViewModel) {
    self.room = room
    self.roomViewModel = roomViewModel
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 0) {
      RoomImage[room.id]
        .resizable()
        .scaledToFill()
        .frame(height: screenHeight * 0.4)
        .clipped()
        .ignoresSafeArea()

      Spacer()
    }
    .sheet(isPresented: $showDetails) {
      RoomDetailsSheetView(room: room, roomViewModel: roomViewModel) {
        showDetails = false
        dismiss()
      }
      .presentationDetents([.fraction(0.65), .fraction(0.75), .large], selection: $detent)
      .presentationBackgroundInteraction(.enabled(upThrough: .large))
      .presentationCornerRadius(30)
      .interactiveDismissDisabled()
    }
    .background(
      NavigationPopObserver {
        showDetails = false
      }
    )
    .navigationBarBackButtonHidden(true)
    .enableSystemBackSwipe()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Back", systemImage: "chevron.left") {
          showDetails = false
          // TODO:
          // clear room bookings here instead of on appear
          dismiss()
        }
        .padding(.vertical, 4)
        .font(.title2)
        .buttonBorderShape(.circle)
        .liquidGlass(
          if: {
            $0
          },
          else: {
            $0
              .buttonStyle(.borderedProminent)
              .tint(.white)
              .foregroundStyle(theme.accent.primary)
          })
      }

      ToolbarItem(placement: .topBarTrailing) {
        Section {
          RoomLabel(leftLabel: "Capacity", rightLabel: String(room.capacity))
        }
        .controlSize(.large)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .liquidGlass(
          if: {
            $0
          },
          else: {
            $0
              .background(Color.white)
              .cornerRadius(12)
          })
      }
    }
  }

  // MARK: Internal

  @Environment(\.dismiss) var dismiss

  // MARK: Private

  @Environment(Theme.self) private var theme

  @State private var detent = PresentationDetent.fraction(0.75)
  @State private var showDetails = true

  private let screenHeight = UIScreen.main.bounds.height
  private let room: Room
  private var roomViewModel: RoomViewModel
}

#Preview {
  NavigationStack {
    RoomDetailsView(room: Room.exampleOne, roomViewModel: PreviewRoomViewModel())
      .defaultTheme()
  }
}

extension View {
  @ViewBuilder
  func liquidGlass(
    if transform1: (Self) -> some View,
    else transform2: (Self) -> some View)
    -> some View
  {
    if #available(iOS 26.0, *) {
      transform1(self)
    } else {
      transform2(self)
    }
  }
}

private struct NavigationPopObserver: UIViewControllerRepresentable {
  let onDismiss: () -> Void

  func makeUIViewController(context: Context) -> Controller {
    Controller(onDismiss: onDismiss)
  }

  func updateUIViewController(_ controller: Controller, context: Context) {
    controller.onDismiss = onDismiss
  }

  class Controller: UIViewController {
    var onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
      self.onDismiss = onDismiss
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      if let coordinator = transitionCoordinator, coordinator.isInteractive {
        // Wait until the interactive gesture is committed (user lifts finger past threshold)
        coordinator.notifyWhenInteractionChanges { context in
          if !context.isCancelled {
            self.onDismiss()
          }
        }
      }
    }
  }
}

private extension View {
    func enableSystemBackSwipe() -> some View {
        self.onAppear {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let navigationController = findNavigationController(in: window.rootViewController) else { return }
            
          navigationController.interactivePopGestureRecognizer?.isEnabled = true
          navigationController.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    // Helper to traverse view controller hierarchy
    private func findNavigationController(in viewController: UIViewController?) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController { return navigationController }
        for child in viewController?.children ?? [] {
            if let found = findNavigationController(in: child) { return found }
        }
        return nil
    }
}
