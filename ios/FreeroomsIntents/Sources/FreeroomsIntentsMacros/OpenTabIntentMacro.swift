//
//  OpenTabIntentMacro.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 29/8/2026.
//

import Foundation
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct OpenTabIntentMacro: DeclarationMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in _: some MacroExpansionContext)
    throws -> [DeclSyntax]
  {
    // First get out the selected tab
    guard
      let argument = node.arguments.first,
      let tabName = argument.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
    else {
      preconditionFailure("\(#function): Missing or unexpected argument for openTab")
    }

    // Construct the new type name
    let intentTypeName = "\(tabName.capitalized)"

    let typeDecl: DeclSyntax = """
      public struct \(raw: intentTypeName): AppIntent {
        public static let title: LocalizedStringResource = "Open \(raw: tabName.capitalized) Tab"
        public static let description = IntentDescription("Opens the \(raw: tabName.capitalized) tab when run")

        public static var openAppWhenRun: Bool {
          true
        }

        @available(iOS 26.0, *)
        public static var supportedModes: IntentModes {
          .foreground(.immediate)
        }

        public init() {}
        
        @Dependency
        private var tabController: TabController

        @MainActor
        public func perform() async throws -> some IntentResult {
          tabController.currentTab = .\(raw: tabName)
          return .result()
        }
      }
      """

    return [
      typeDecl,
    ]
  }
}
