//
//  CustomDropdownPicker.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 9/12/25.
//

import SwiftUI

struct CustomDropdownPicker: View {
    let hint: String
//    var options: [String]
    @Binding var selection: String
    @Binding var showDropdown: Bool
    
    @StateObject var minifiguresVM = MinifiguresVM()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDropdown.toggle()
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? hint : selection)
                        .foregroundStyle(selection.isEmpty ? .secondary: .primary)
                        .font(.system(size: 14))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showDropdown ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showDropdown)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
            }
            
            if showDropdown {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(LegoThemes.allCases, id: \.id) { option in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selection = option.rawValue
                                    showDropdown = false
                                }
                            }) {
                                HStack {
                                    Text(option.displayName)
                                        .tag(option.rawValue)
                                        .foregroundColor(.primary)
                                        .font(.system(size: 14))
                                    Spacer()
                                    if selection == option.rawValue {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 12))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(selection == option.rawValue ? Color.blue.opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
//                            if option != options.last?.rawValue {
//                                Divider()
//                                    .padding(.horizontal, 12)
//                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .offset(y: 4)
                    .zIndex(1000)
                }
                .cornerRadius(15)
                .shadow(radius: 5)
//                .zIndex(200)
            }
        }
        .frame(width: 140)
    }
}

//#Preview {
//    CustomDropdownPicker()
//}

/*
 //
 //  MinifiguresView.swift
 //  Brick Finder
 //
 //  Created by AI Assistant
 //

 import SwiftUI

 struct MinifiguresView: View {
     @StateObject var viewModel = MinifigureVM()
     @State private var showDropdown = false
     @State private var selectedTheme = "All Themes"
     
     let themes = ["All Themes", "City", "Star Wars", "Creator", "Ninjago", "Friends", "Technic"]
     
     var body: some View {
         ZStack {
             VStack(spacing: 24) {
                 // Header
                 headerView
                 
                 // Filters
                 HStack {
                     CustomDropdownPicker(
                         hint: "Theme",
                         options: themes,
                         selection: $selectedTheme,
                         showDropdown: $showDropdown
                     )
                     Spacer()
                 }
                 .padding(.horizontal)
                 .zIndex(showDropdown ? 1000 : 1)
                 
                 // Minifigures Grid
                 ScrollView {
                     minifiguresGrid
                 }
                 .zIndex(showDropdown ? 1 : 100)
             }
         }
         .onTapGesture {
             if showDropdown {
                 withAnimation(.easeInOut(duration: 0.2)) {
                     showDropdown = false
                 }
             }
         }
     }
     
     private var headerView: some View {
         VStack(alignment: .leading, spacing: 16) {
             HStack {
                 Text("Lego Minifigures")
                     .font(.system(size: 24, weight: .bold))
                     .foregroundStyle(Color.primary)
                 Spacer()
             }
             
             SearchBar(searchText: $viewModel.searchText)
         }
         .padding(.horizontal)
     }
     
     private var minifiguresGrid: some View {
         LazyVGrid(columns: [
             GridItem(.flexible()),
             GridItem(.flexible())
         ], spacing: 16) {
             if let minifigures = viewModel.minifigures {
                 ForEach(minifigures, id: \.name) { minifigure in
                     MinifigureCardView(minifigure: minifigure)
                 }
             }
         }
         .padding(.horizontal)
     }
 }

 struct CustomDropdownPicker: View {
     let hint: String
     let options: [String]
     @Binding var selection: String
     @Binding var showDropdown: Bool
     
     var body: some View {
         VStack(alignment: .leading, spacing: 0) {
             // Dropdown Button
             Button(action: {
                 withAnimation(.easeInOut(duration: 0.2)) {
                     showDropdown.toggle()
                 }
             }) {
                 HStack {
                     Text(selection.isEmpty ? hint : selection)
                         .foregroundColor(selection.isEmpty ? .secondary : .primary)
                         .font(.system(size: 14))
                     
                     Spacer()
                     
                     Image(systemName: "chevron.down")
                         .foregroundColor(.secondary)
                         .rotationEffect(.degrees(showDropdown ? 180 : 0))
                         .animation(.easeInOut(duration: 0.2), value: showDropdown)
                 }
                 .padding(.horizontal, 12)
                 .padding(.vertical, 10)
                 .background(Color(.systemGray6))
                 .cornerRadius(8)
                 .overlay(
                     RoundedRectangle(cornerRadius: 8)
                         .stroke(Color(.systemGray4), lineWidth: 1)
                 )
             }
             
             // Dropdown Menu
             if showDropdown {
                 VStack(alignment: .leading, spacing: 0) {
                     ForEach(options, id: \.self) { option in
                         Button(action: {
                             withAnimation(.easeInOut(duration: 0.2)) {
                                 selection = option
                                 showDropdown = false
                             }
                         }) {
                             HStack {
                                 Text(option)
                                     .foregroundColor(.primary)
                                     .font(.system(size: 14))
                                 Spacer()
                                 if selection == option {
                                     Image(systemName: "checkmark")
                                         .foregroundColor(.blue)
                                         .font(.system(size: 12))
                                 }
                             }
                             .padding(.horizontal, 12)
                             .padding(.vertical, 10)
                             .background(selection == option ? Color.blue.opacity(0.1) : Color.clear)
                         }
                         .buttonStyle(PlainButtonStyle())
                         
                         if option != options.last {
                             Divider()
                                 .padding(.horizontal, 12)
                         }
                     }
                 }
                 .background(Color(.systemBackground))
                 .cornerRadius(8)
                 .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                 .overlay(
                     RoundedRectangle(cornerRadius: 8)
                         .stroke(Color(.systemGray4), lineWidth: 1)
                 )
                 .offset(y: 4)
                 .zIndex(1000)
             }
         }
         .frame(width: 140)
     }
 }

 struct MinifigureCardView: View {
     let minifigure: Minifigure
     
     var body: some View {
         VStack(spacing: 12) {
             // Minifigure Image
             AsyncImage(url: URL(string: minifigure.image)) { image in
                 image
                     .resizable()
                     .aspectRatio(contentMode: .fit)
             } placeholder: {
                 RoundedRectangle(cornerRadius: 8)
                     .fill(Color(.systemGray5))
                     .overlay(
                         Image(systemName: "person.fill")
                             .foregroundColor(.gray)
                             .font(.system(size: 24))
                     )
             }
             .frame(height: 120)
             .cornerRadius(8)
             
             // Minifigure Info
             VStack(alignment: .leading, spacing: 4) {
                 Text(minifigure.name)
                     .font(.system(size: 14, weight: .semibold))
                     .foregroundColor(.primary)
                     .lineLimit(2)
                 
                 Text(minifigure.theme)
                     .font(.system(size: 12))
                     .foregroundColor(.secondary)
                 
                 HStack {
                     Image(systemName: "calendar")
                         .font(.system(size: 10))
                         .foregroundColor(.secondary)
                     Text("\(minifigure.year)")
                         .font(.system(size: 12))
                         .foregroundColor(.secondary)
                 }
             }
             .frame(maxWidth: .infinity, alignment: .leading)
         }
         .padding(12)
         .background(Color(.systemBackground))
         .cornerRadius(12)
         .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
     }
 }

 // Sample Data Models
 struct Minifigure {
     let name: String
     let theme: String
     let year: Int
     let image: String
     let parts: [MinifigurePart]
 }

 struct MinifigurePart {
     let name: String
     let partNumber: String
     let image: String
 }

 // Sample ViewModel
 class MinifigureVM: ObservableObject {
     @Published var minifigures: [Minifigure]?
     @Published var searchText = ""
     
     init() {
         loadMinifigures()
     }
     
     func loadMinifigures() {
         // Sample data - replace with your actual data loading
         minifigures = [
             Minifigure(name: "Police Officer", theme: "City", year: 2023, image: "", parts: []),
             Minifigure(name: "Firefighter", theme: "City", year: 2023, image: "", parts: []),
             // Add more sample data
         ]
     }
 }

 #Preview {
     MinifiguresView()
 }

 */
