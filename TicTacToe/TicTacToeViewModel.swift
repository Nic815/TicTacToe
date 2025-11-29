//
//  TicTacToeViewModel.swift
//  TicTacToe
//
//  Created by NIKHIL on 29/11/25.
//

import SwiftUI
import Combine

final class TicTacToeViewModel: ObservableObject {

    @Published var board: [Player?] = Array(repeating: nil, count: 9)
    @Published var currentPlayer: Player = .x
    @Published var winner: Player? = nil
    @Published var winningIndices: [Int] = []
    @Published var isDraw: Bool = false

    private let winningLines: [[Int]] = [
        [0,1,2], [3,4,5], [6,7,8], // rows
        [0,3,6], [1,4,7], [2,5,8], // columns
        [0,4,8], [2,4,6]           // diagonals
    ]

    func resetGame(startingPlayer: Player = .x) {
        withAnimation {
            board = Array(repeating: nil, count: 9)
            currentPlayer = startingPlayer
            winner = nil
            winningIndices = []
            isDraw = false
        }
    }

    func makeMove(at index: Int) {
        // Validate
        guard index >= 0 && index < 9 else { return }
        guard board[index] == nil else { return }         
        guard winner == nil && !isDraw else { return }

        // Place mark
        board[index] = currentPlayer

        // Check for win
        if let win = detectWinner() {
            winner = currentPlayer
            winningIndices = win
        } else if board.compactMap({ $0 }).count == 9 {
            // Board full and no winner => draw
            isDraw = true
        } else {
            // Switch turn
            currentPlayer = currentPlayer.next
        }
    }

    private func detectWinner() -> [Int]? {
        for line in winningLines {
            let marks = line.map { board[$0] }
            if marks.allSatisfy({ $0 == .x }) || marks.allSatisfy({ $0 == .o }) {
                return line
            }
        }
        return nil
    }
}
