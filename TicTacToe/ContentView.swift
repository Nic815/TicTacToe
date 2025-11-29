//
//  ContentView.swift
//  TicTacToe
//
//  Created by NIKHIL on 29/11/25.
//


import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var vm = TicTacToeViewModel()
    @State private var placedScale: [CGFloat] = Array(repeating: 1.0, count: 9)
    @State private var lastTapTime: Date = .distantPast
    @State private var showResultAlert: Bool = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private let cellMinSide: CGFloat = 88

    var body: some View {
        VStack(spacing: 20) {
            header

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0..<9) { i in
                    cellView(at: i)
                        .frame(minWidth: cellMinSide, minHeight: cellMinSide)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))
            .shadow(radius: 8)

            statusText
            controls

            Spacer()
        }
        .padding()
        .onAppear {
            vm.resetGame()
            placedScale = Array(repeating: 1.0, count: 9)
        }
        .onChange(of: vm.board) { _ in
            animatePlacedMarks()
        }
        
        .onChange(of: vm.winner) { newValue in
            if newValue != nil {
                showResultAlert = true
            }
        }
        .onChange(of: vm.isDraw) { newValue in
            if newValue {
                showResultAlert = true
            }
        }
        .alert(isPresented: $showResultAlert) {
            if let winner = vm.winner {
                // WIN alert
                return Alert(
                    title: Text("Player \(winner.rawValue) wins! 🎉"),
                    message: Text("Tap Restart to play again."),
                    dismissButton: .default(Text("OK"))
                )
            } else {
               
                return Alert(
                    title: Text("It's a draw."),
                    message: Text("Nobody won this round."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Text("Tic-Tac-Toe")
                .font(.largeTitle).bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text("Turn")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let winner = vm.winner {
                    Text("\(winner.rawValue) wins")
                        .font(.headline)
                        .foregroundColor(winner.color)
                } else if vm.isDraw {
                    Text("Draw")
                        .font(.headline)
                } else {
                    Text(vm.currentPlayer.rawValue)
                        .font(.headline)
                        .foregroundColor(vm.currentPlayer.color)
                }
            }
        }
    }

    // MARK: Cell
    private func cellView(at index: Int) -> some View {
        let mark = vm.board[index]
        let isWinning = vm.winningIndices.contains(index)

        return ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.28), lineWidth: 1.5)
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isWinning ? Color.yellow.opacity(0.25) : Color.clear)
                )

            if let p = mark {
                Text(p.rawValue)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundColor(p.color)
                    .scaleEffect(placedScale[index])
                    .animation(.spring(response: 0.36, dampingFraction: 0.65), value: placedScale[index])
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap(at: index)
        }
    }

    private func handleTap(at index: Int) {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) < 0.06 {
            return
        }
        lastTapTime = now

        guard index >= 0 && index < vm.board.count else { return }
        guard vm.board[index] == nil else { return }
        guard vm.winner == nil && !vm.isDraw else { return }

        vm.makeMove(at: index)

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        placedScale[index] = 0.6
    }

    // MARK: Status & controls
    private var statusText: some View {
        Group {
            if let winner = vm.winner {
                Text("Player \(winner.rawValue) wins!")
                    .font(.headline)
                    .foregroundColor(winner.color)
            } else if vm.isDraw {
                Text("It's a draw.")
                    .font(.headline)
            } else {
                Text("Turn: \(vm.currentPlayer.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(vm.currentPlayer.color)
            }
        }
        .padding(.top, 6)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                vm.resetGame(startingPlayer: .x)
                placedScale = Array(repeating: 1.0, count: 9)
                showResultAlert = false
            } label: {
                Label("Restart (X starts)", systemImage: "arrow.counterclockwise.circle")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
            }

            Button {
                vm.resetGame(startingPlayer: .o)
                placedScale = Array(repeating: 1.0, count: 9)
                showResultAlert = false
            } label: {
                Label("Restart (O starts)", systemImage: "arrow.counterclockwise")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
            }
        }
        .font(.subheadline)
    }

    // MARK: Animation helper
    private func animatePlacedMarks() {
        for i in 0..<vm.board.count {
            if vm.board[i] != nil {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.65)) {
                    placedScale[i] = 1.0
                }
            } else {
                placedScale[i] = 1.0
            }
        }
    }
}
