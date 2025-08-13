//
//  AddItemView.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/12/25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add New Item")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AddItemView()
}
