//
//  SearchInstructionView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 3/30/26.
//

import SwiftUI

struct SearchInstructionView: View {
    @StateObject var viewModel = SetVM()
    
    var body: some View {
        VStack(spacing: 24) {
            searchView
            
            displayInstructions
        }
    }
    
    private var searchView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
            TextField("LEGO set number (e.g. 75192)", text: $viewModel.searchText)
                .submitLabel(.search)
                .onSubmit { viewModel.getLegoIntructions(with: viewModel.searchText) }
            Button("Search") {
                viewModel.getLegoIntructions(with: viewModel.searchText)
            }
            .buttonStyle(.borderedProminent)
        }
        .font(.headline)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(Color.gray)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var displayInstructions: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading instructions…")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Couldn’t load instructions")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else if let instructions = viewModel.instructions, !instructions.isEmpty {
                    ForEach(instructions) { lego in
                        instructionCard(instruction: lego)
                    }
                } else if viewModel.instructions != nil {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No instructions found")
                            .font(.headline)
                        Text("Try another set number. Brickset accepts numbers like 75192 or 75192-1.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Search for a set")
                            .font(.headline)
                        Text("Enter a set number, then tap Search or the keyboard search key.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.hidden)
    }
    
    private func instructionCard(instruction: Instructions.InstructionsResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: "doc.richtext.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    // Description
                    if let description = instruction.description, !description.isEmpty {
                        Text(description)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Building Instructions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    // URL Link
                    if let urlString = instruction.url,
                       let url = URL(string: urlString) {
                        Link(destination: url) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                Text("Open Instructions")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.caption)
                            Text("No URL available")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    SearchInstructionView()
}
