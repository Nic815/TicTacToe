//
//  Models.swift
//  TicTacToe
//
//  Created by NIKHIL on 29/11/25.
//

import SwiftUI

enum Player: String, Codable {
    case x = "X"
    case o = "O"

    var next: Player { self == .x ? .o : .x }
    var color: Color { self == .x ? .blue : .red }
}
