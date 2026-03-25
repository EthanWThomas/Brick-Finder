//
//  LegoInstructionsView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 2/12/26.
//

import SwiftUI

struct LegoInstructionsView: View {
    var legoSet: LegoSet.SetResults
    
    @ObservedObject var viewModel: SetVM
    
    var body: some View {
        displayInstructions
            .task(id: legoSet.setNumber ?? "") {
                let setNum = legoSet.setNumber ?? ""
                guard !setNum.isEmpty else { return }
                await MainActor.run {
                    viewModel.getLegoIntructions(with: setNum)
                }
            }
    }
    
    private var displayInstructions: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error loading instructions")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else if let legoInstructions = viewModel.instructions, !legoInstructions.isEmpty {
                    ForEach(legoInstructions, id: \.id) { instruction in
                        instructionCard(instruction: instruction)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No instructions found")
                            .font(.headline)
                        Text("This set may not have building instructions available.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                }
            }
            .padding(15)
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


