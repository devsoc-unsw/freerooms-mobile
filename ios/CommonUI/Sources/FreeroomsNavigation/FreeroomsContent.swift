//
//  FreeroomsContent.swift
//  CommonUI
//
//  Created by Matthew Yuen on 28/11/2026.
//

public import SwiftUI
public import VISOR

public protocol FreeroomsContentBuilderProtocol {
  associatedtype PushContent: View
  associatedtype SheetContent: View
  associatedtype FullScreenContent: View
  
  var pushContent: (FreeroomsNavigationScene.Push) -> PushContent { get }
  var sheetContent: (FreeroomsNavigationScene.Sheet) -> SheetContent { get }
  var fullScreenContent: (FreeroomsNavigationScene.FullScreen) -> FullScreenContent { get }
}

public struct FreeroomsContentBuilder<
  PushContent: View,
  SheetContent: View,
  FullScreenContent: View
>: FreeroomsContentBuilderProtocol {
  public typealias Scene = FreeroomsNavigationScene
  
  public let pushContent: (Scene.Push) -> PushContent
  public let sheetContent: (Scene.Sheet) -> SheetContent
  public let fullScreenContent: (Scene.FullScreen) -> FullScreenContent
  
  public init(
    @ViewBuilder pushContent: @escaping (Scene.Push) -> PushContent,
    @ViewBuilder sheetContent: @escaping (Scene.Sheet) -> SheetContent,
    @ViewBuilder fullScreenContent: @escaping (Scene.FullScreen) -> FullScreenContent
  ) {
    self.pushContent = pushContent
    self.sheetContent = sheetContent
    self.fullScreenContent = fullScreenContent
  }
}
