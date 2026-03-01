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
      .presentationBackgroundInteraction(.enabled)
      .presentationCornerRadius(30)
      .interactiveDismissDisabled()
    }
    .background(
      NavigationPopObserver {
        showDetails = false
      })
    .navigationBarBackButtonHidden(true)
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

// MARK: - NavigationPopObserver

/// Observes the navigation controller's interactive pop gesture to:
/// 1. Dismiss the room availability sheet when the pop completes.
/// 2. Shrink the sheet height proportionally during the back-swipe.
///
/// Sheet tracking works entirely through UIKit to avoid SwiftUI re-renders
/// that would fight the detent changes. On gesture `.began` the current
/// `UISheetPresentationController` detents are saved and replaced with a
/// single custom detent whose height is re-resolved via `invalidateDetents()`
/// on each `.changed` event. If the pop is cancelled the original detents
/// are restored with `animateChanges`.
private struct NavigationPopObserver: UIViewControllerRepresentable {
  class Controller: UIViewController {

    // MARK: Lifecycle

    init(onDismiss: @escaping () -> Void) {
      self.onDismiss = onDismiss
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    // MARK: Internal

    var onDismiss: () -> Void

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      guard gestureRecogniser == nil, let nav = navigationController else { return }
      // Re-enable the system back swipe disabled by .navigationBarBackButtonHidden(true)
      nav.interactivePopGestureRecognizer?.isEnabled = true
      nav.interactivePopGestureRecognizer?.delegate = nil
      if let recogniser = nav.interactivePopGestureRecognizer {
        recogniser.addTarget(self, action: #selector(handlePopGesture(_:)))
        gestureRecogniser = recogniser
      }
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      gestureRecogniser?.removeTarget(self, action: #selector(handlePopGesture(_:)))
      gestureRecogniser = nil
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

    // MARK: Private

    private weak var gestureRecogniser: UIGestureRecognizer?
    private var isTrackingSwipe = false

    // Sheet height tracking — all state lives here (not in SwiftUI)
    // so that updates bypass the render loop and go straight to UIKit.
    private weak var sheetController: UISheetPresentationController?
    private var savedDetents: [UISheetPresentationController.Detent] = []
    private var savedSelectedIdentifier: UISheetPresentationController.Detent.Identifier?
    private var baseHeight: CGFloat = 0
    private var targetHeight: CGFloat = 0

    /// Custom detent whose resolver re-reads `targetHeight` each time
    /// `invalidateDetents()` is called, giving smooth per-frame tracking.
    private lazy var dynamicDetent: UISheetPresentationController.Detent =
      .custom(identifier: .init("swipe")) { [weak self] _ in
        self?.targetHeight
      }

    /// Walks up the view controller hierarchy to find the presented sheet.
    private func findSheetController() -> UISheetPresentationController? {
      var vc: UIViewController? = self
      while let current = vc {
        if let sheet = current.presentedViewController?.sheetPresentationController {
          return sheet
        }
        vc = current.parent
      }
      return nil
    }

    private func restoreDetents() {
      guard let sheet = sheetController else { return }
      sheet.animateChanges {
        sheet.detents = self.savedDetents
        sheet.selectedDetentIdentifier = self.savedSelectedIdentifier
      }
    }

    @objc
    private func handlePopGesture(_ recogniser: UIPanGestureRecognizer) {
      let screenWidth = view.bounds.width
      guard screenWidth > 0 else { return }

      switch recogniser.state {
      case .began:
        guard let sheet = findSheetController() else { return }
        sheetController = sheet
        savedDetents = sheet.detents
        savedSelectedIdentifier = sheet.selectedDetentIdentifier
        baseHeight = sheet.presentedView?.frame.height ?? 0
        targetHeight = baseHeight
        isTrackingSwipe = true
        sheet.detents = [dynamicDetent]
        sheet.selectedDetentIdentifier = .init("swipe")

      case .changed:
        guard isTrackingSwipe else { return }
        let translation = recogniser.translation(in: view).x
        let progress = min(max(translation / screenWidth, 0), 1)
        targetHeight = max(1, baseHeight * (1 - progress))
        sheetController?.invalidateDetents()

      case .ended, .cancelled:
        guard isTrackingSwipe else { return }
        isTrackingSwipe = false

        if recogniser.state == .cancelled {
          restoreDetents()
          return
        }

        if let transCoord = navigationController?.transitionCoordinator {
          transCoord.notifyWhenInteractionChanges { [weak self] context in
            guard let self, context.isCancelled else { return }
            restoreDetents()
          }
        } else {
          restoreDetents()
        }

      default:
        break
      }
    }
  }

  let onDismiss: () -> Void

  func makeUIViewController(context _: Context) -> Controller {
    Controller(onDismiss: onDismiss)
  }

  func updateUIViewController(_ controller: Controller, context _: Context) {
    controller.onDismiss = onDismiss
  }

}
