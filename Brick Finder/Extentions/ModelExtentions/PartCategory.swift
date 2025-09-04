//
//  PartCategory.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/17/25.
//

import Foundation

enum PartCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case Bars = "32"
    case Baseplates = "1"
    case Belville = "42"
    case Fabuland = "57"
    case Brick = "11"
    case Brick_Curved = "37"
    case Brick_Round_Cone = "20"
    case Brick_Sloped = "3"
    case Brick_Wedged = "5"
    case Clikits = "48"
    case Container = "7"
    case Duplo_Quartro_Primo
    case Electronics = "45"
    case Energy_Effects = "69"
    case Flag_Signs_Plastics_Cloth
    case Minifig_Accessories = "27"
    case Minifig_Heads = "59"
    case Minifig_Lower_Body = "61"
    case Minfig = "13"
    case Minifig_Upper_Body = "60"
    case Minifig_Headwear = "65"
    case Modulex = "66"
    case Other = "24"
    case Plates = "14"
    case Panels = "23"
    case Znap = "43"
    case Rock = "33"
    case Tools = "21"
    case Wheels_and_Tyres = "58"
    case Tubes_and_Hoses = "30"
    case Tiles = "19"
    case Tiles_Round_and_Curved = "67"
    case Tiles_Special = "15"
    case Technic_Bricks = "8"
    case Technic_Bushes = "54"
    case Technic_Gears = "52"
    case Technic_Panels = "40"
    case Technic_Pins = "53"
    case Technic_Axles = "46"
    case Transportation_Land = "36"
    case Pneumatics = "22"
    case Mechanical = "44"
    case Transportation_Sea_and_Air = "35"
    case HO_Scale = "50"
    case Windows_and_Doors = "16"
    case Hinges_Arms_and_Turntables = "18"
    case Plates_Angled = "49"
    case Windscreens_and_Fuselage = "47"
    case Large_Buildable_Figures = "41"
}

extension PartCategory {
    var displayName: String {
        switch self {
            case .Bars:
                return "Bars, Ladders And Fences"
            case .Baseplates:
                return "Baseplates"
            case .Belville:
                return "Belville"
            case .Fabuland:
                return "Fabuland"
            case .Brick:
                return "Brick"
            case .Brick_Curved:
                return "Brick Curved"
            case .Brick_Round_Cone:
                return "Brick Round Cone"
            case .Brick_Sloped:
                return "Brick Sloped"
            case .Brick_Wedged:
                return "Brick Wedged"
            case .Clikits:
                return "Clikits"
            case .Container:
                return "Container"
            case .Duplo_Quartro_Primo:
                return "Duplo Quartro Primo"
            case .Electronics:
                return "Electronics"
            case .Energy_Effects:
                return "Energy Effects"
            case .Flag_Signs_Plastics_Cloth:
                return "Flag Signs Plastics Cloth"
            case .Minifig_Accessories:
                return "Minifig Accessories"
            case .Minifig_Heads:
                return "Minifig Heads"
            case .Minifig_Lower_Body:
                return "Minifig Lower Body"
            case .Minfig:
                return "Minfig"
            case .Minifig_Upper_Body:
                return "Minifig Upper Body"
            case .Minifig_Headwear:
                return "Minifig Headwear"
            case .Modulex:
                return "Modulex"
            case .Other:
                return "Other"
            case .Plates:
                return "Plates"
            case .Panels:
                return "Panels"
            case .Znap:
                return "Znap"
            case .Rock:
                return "Rock"
            case .Tools:
                return "Tools"
            case .Wheels_and_Tyres:
                return "Wheels and Tyres"
            case .Tubes_and_Hoses:
                return "Tubes and Hoses"
            case .Tiles:
                return "Tiles"
            case .Tiles_Round_and_Curved:
                return "Tiles Round and Curved"
            case .Tiles_Special:
                return "Tiles Special"
            case .Technic_Bricks:
                return "Technic Bricks"
            case .Technic_Bushes:
                return "Technic Bushes"
            case .Technic_Gears:
                return "Technic Gears"
            case .Technic_Panels:
                return "Technic Panels"
            case .Technic_Pins:
                return "Technic Pins"
            case .Technic_Axles:
                return "Technic Axles"
            case .Transportation_Land:
                return "Transportation Land"
            case .Pneumatics:
                return "Pneumatics"
            case .Mechanical:
                return "Mechanical"
            case .Transportation_Sea_and_Air:
                return "Transportation Sea and Air"
            case .HO_Scale:
                return "HO Scale"
            case .Windows_and_Doors:
                return "Windows and Doors"
            case .Hinges_Arms_and_Turntables:
                return "Hinges Arms and Turntables"
            case .Plates_Angled:
                return "Plates Angled"
            case .Windscreens_and_Fuselage:
                return "Windscreens and Fuselage"
            case .Large_Buildable_Figures:
                return "Large Buildable Figures"
        }
    }
}


