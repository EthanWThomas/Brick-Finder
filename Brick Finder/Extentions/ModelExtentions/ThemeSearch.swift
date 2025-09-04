//
//  ThemeSearch.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/17/25.
//

import Foundation

enum LegoThemes: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case Star_Wars = "158"
    case Monkie_Kid = "693"
    case Blueys = "772"
    case Castle = "198"
    case City = "57"
    case Cars = "269"
    case Space = "127"
    case Ninjago = "435"
    case Collectible_Minifigures = "555"
    case Disney = "687"
    case Dreamzzz = "749"
    case Eives = "600"
    case SpongeBob_SquarePants = "272"
    case Harry_Potter = "246"
    case Legends_of_Chima = "571"
    case Minecraft = "577"
    case Pirates = "148"
    case Super_Heros_DC = "698"
    case Super_Heros_DC_Girls = "517"
    case Super_Heros_Marvel = "706"
    case Avatar = "724"
    case Avatar_The_Last_Airbender = "317"
    case Architecture = "252"
    case Alpha_Team = "304"
    case Aquazone = "310"
    case Atlantis = "315"
    case Animal_Crossing = "752"
    case Despicable_Me_4 = "763"
    case ScoobyDoo = "603"
    case Speed_Racer = "717"
    case Speed_Champions = "601"
    case Friend = "494"
    case One_Piece = "775"
    case LEGO_Ideas_and_CUUSOO = "576"
    case Sonic_The_Hedgehog = "747"
    case Jurassic_World = "602"
    case Teenage_Mutant_Ninja_Turtles = "570"
    case The_LEGO_Movie = "578"
    case The_Hobbit_and_Lord_of_the_Rings = "562"
    case Unikitty = "625"
    case Toy_Story = "275"
}

extension LegoThemes {
    var displayName: String {
        switch self {
            case .Star_Wars:
                return "Star Wars"
            case .Monkie_Kid:
                return "Monkie Kid"
            case .Castle:
                return "Castle"
            case .City:
                return "City"
            case .Space:
                return "Space"
            case .Ninjago:
                return "Ninjago"
            case .Collectible_Minifigures:
                return "Collectible Minifigures"
            case .Disney:
                return "Disney"
            case .Eives:
                return "Eives"
            case .SpongeBob_SquarePants:
                return "SpongeBob SquarePants"
            case .Harry_Potter:
                return "Harry Potter"
            case .Legends_of_Chima:
                return "Legends of Chima"
            case .Minecraft:
                return "Minecraft"
            case .Pirates:
                return "Pirates"
            case .Super_Heros_DC:
                return "Super Heros DC"
            case .Super_Heros_Marvel:
                return "Super Heros Marvel"
            case.Super_Heros_DC_Girls:
                return "Super Heros DC Girls"
            case .Avatar:
                return "Avatar"
            case .Avatar_The_Last_Airbender:
                return "Avatar The Last Airbender"
            case .Despicable_Me_4:
                return "Despicable Me 4"
            case .ScoobyDoo:
                return "ScoobyDoo"
            case .Speed_Racer:
                return "Speed Racer"
            case .Speed_Champions:
                return "Speed Champions"
            case .Friend:
                return "Friend"
            case .One_Piece:
                return "One Piece"
            case .LEGO_Ideas_and_CUUSOO:
                return "LEGO Ideas and CUUSOO"
            case .Sonic_The_Hedgehog:
                return "Sonic The Hedgehog"
            case .Aquazone:
                return "Aquazone"
            case .Animal_Crossing:
                return "Animal Crossing"
            case .Architecture:
                return "Architecture"
            case .Alpha_Team:
                return "Alpha Team"
            case .Jurassic_World:
                return "Jurassic World"
            case .Blueys:
                return "Blueys"
            case .Atlantis:
                return "Atlantis"
            case .Dreamzzz:
                return "Dreamzzz"
            case .Cars:
                return "Cars"
            case .Teenage_Mutant_Ninja_Turtles:
                return "Teenage Mutant Ninja Turtles"
            case .The_LEGO_Movie:
                return "The LEGO Movie"
            case .The_Hobbit_and_Lord_of_the_Rings:
                return "The Hobbit and Lord of the Rings"
            case .Unikitty:
                return "Unikitty!"
            case .Toy_Story:
                return "Toy Story"
        }
    }
}


