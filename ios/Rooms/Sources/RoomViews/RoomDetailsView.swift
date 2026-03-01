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
      .background(SheetDetentBridge(coordinator: sheetCoordinator))
      .presentationDetents([.fraction(0.65), .fraction(0.75), .large], selection: $detent)
      .presentationBackgroundInteraction(.enabled)
      .presentationCornerRadius(30)
      .interactiveDismissDisabled()
    }
    .background(
      NavigationPopObserver(
        coordinator: sheetCoordinator,
        onDismiss: { showDetails = false }
      )
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
  @State private var sheetCoordinator = SheetSwipeCoordinator()

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

// MARK: - SheetSwipeCoordinator

private class SheetSwipeCoordinator {
  weak var sheetController: UISheetPresentationController?

  private var savedDetents: [UISheetPresentationController.Detent] = []
  private var savedSelectedIdentifier: UISheetPresentationController.Detent.Identifier?
  private var baseHeight: CGFloat = 0
  private var targetHeight: CGFloat = 0
  private(set) var isActive = false

  private lazy var dynamicDetent: UISheetPresentationController.Detent =
    .custom(identifier: .init("swipe")) { [weak self] _ in
      self?.targetHeight
    }

  func beginSwipe() {
    guard let sheet = sheetController else { return }
    savedDetents = sheet.detents
    savedSelectedIdentifier = sheet.selectedDetentIdentifier
    baseHeight = sheet.presentedView?.frame.height ?? 0
    targetHeight = baseHeight
    isActive = true
    sheet.detents = [dynamicDetent]
    sheet.selectedDetentIdentifier = .init("swipe")
  }

  func updateSwipe(progress: CGFloat) {
    guard isActive else { return }
    targetHeight = max(1, baseHeight * (1 - progress))
    sheetController?.invalidateDetents()
  }

  func endSwipe(cancelled: Bool) {
    guard isActive else { return }
    isActive = false
    guard cancelled, let sheet = sheetController else { return }
    sheet.animateChanges {
      sheet.detents = self.savedDetents
      sheet.selectedDetentIdentifier = self.savedSelectedIdentifier
    }
  }
}

// MARK: - SheetDetentBridge

/// Embedded inside the sheet content to capture the UISheetPresentationController reference.
private struct SheetDetentBridge: UIViewControllerRepresentable {
  let coordinator: SheetSwipeCoordinator

  func makeUIViewController(context: Context) -> Controller {
    Controller(coordinator: coordinator)
  }

  func updateUIViewController(_ controller: Controller, context: Context) {
    controller.coordinator = coordinator
  }

  class Controller: UIViewController {
    var coordinator: SheetSwipeCoordinator

    init(coordinator: SheetSwipeCoordinator) {
      self.coordinator = coordinator
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      coordinator.sheetController = sheetPresentationController
    }
  }
}

// MARK: - NavigationPopObserver

private struct NavigationPopObserver: UIViewControllerRepresentable {
  let coordinator: SheetSwipeCoordinator
  let onDismiss: () -> Void

  func makeUIViewController(context: Context) -> Controller {
    Controller(coordinator: coordinator, onDismiss: onDismiss)
  }

  func updateUIViewController(_ controller: Controller, context: Context) {
    controller.coordinator = coordinator
    controller.onDismiss = onDismiss
  }

  class Controller: UIViewController {
    var coordinator: SheetSwipeCoordinator
    var onDismiss: () -> Void

    init(coordinator: SheetSwipeCoordinator, onDismiss: @escaping () -> Void) {
      self.coordinator = coordinator
      self.onDismiss = onDismiss
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    private weak var gestureRecognizer: UIGestureRecognizer?
    private var isTrackingSwipe = false

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      guard gestureRecognizer == nil else { return }
      if let recognizer = navigationController?.interactivePopGestureRecognizer {
        recognizer.addTarget(self, action: #selector(handlePopGesture(_:)))
        gestureRecognizer = recognizer
      }
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      gestureRecognizer?.removeTarget(self, action: #selector(handlePopGesture(_:)))
      gestureRecognizer = nil
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)

      if let coord = transitionCoordinator, coord.isInteractive {
        coord.notifyWhenInteractionChanges { context in
          if !context.isCancelled {
            self.onDismiss()
          }
        }
      }
    }

    @objc private func handlePopGesture(_ recognizer: UIPanGestureRecognizer) {
      let screenWidth = view.bounds.width
      guard screenWidth > 0 else { return }

      switch recognizer.state {
      case .began:
        coordinator.beginSwipe()
        isTrackingSwipe = true

      case .changed:
        guard isTrackingSwipe else { return }
        let translation = recognizer.translation(in: view).x
        let progress = min(max(translation / screenWidth, 0), 1)
        coordinator.updateSwipe(progress: progress)

      case .ended, .cancelled:
        guard isTrackingSwipe else { return }
        isTrackingSwipe = false

        if recognizer.state == .cancelled {
          coordinator.endSwipe(cancelled: true)
          return
        }

        if let transCoord = navigationController?.transitionCoordinator {
          transCoord.notifyWhenInteractionChanges { [weak self] context in
            guard let self else { return }
            self.coordinator.endSwipe(cancelled: context.isCancelled)
          }
        } else {
          coordinator.endSwipe(cancelled: true)
        }

      default:
        break
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
