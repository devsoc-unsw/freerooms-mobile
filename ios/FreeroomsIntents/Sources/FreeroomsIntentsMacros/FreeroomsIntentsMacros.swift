//
//  FreeroomsIntentsMacros.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 28/8/2026.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct FreeroomsIntentsMacros: CompilerPlugin {
  let providingMacros: [any Macro.Type] = [
    OpenTabIntentMacro.self,
  ]
}
