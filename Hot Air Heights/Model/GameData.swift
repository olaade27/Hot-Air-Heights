//
//  Background.swift
//  Hot Air Heights
//
//  Created by Ola Adeoba on 2024-08-05.
//

import Foundation
import SpriteKit


struct currency: Codable {
    var name: String
    var number: String
}
struct Pickupitems: Codable {
    var name: String
    var number: String
}
struct BackgroundItems: Codable {
    var name: String
    var number: String
}
struct colisionItems: Codable {
    var name: String
    var number: String
}
struct SceneItems : Codable{
    var currency : [currency]
    var Pickupitems: [Pickupitems]
    var BackgroundItems: [BackgroundItems]?
    var colisionItems: [colisionItems]?
}
struct sceneBackground : Codable {
    var background: [String]
    var BackgroundSpeed : Double
    var fallDistance : Double
    var fallDuration : Double
    var scene: SceneItems
    
        enum CodingKeys: String, CodingKey {
            case background, BackgroundSpeed, fallDistance, fallDuration, scene
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode arrays and nested objects normally
            background = try container.decode([String].self, forKey: .background)
            scene = try container.decode(SceneItems.self, forKey: .scene)
            
            // Decode and convert string values to Double
            let speedString = try container.decode(String.self, forKey: .BackgroundSpeed)
            BackgroundSpeed = Double(speedString) ?? 0.0
            
            let distanceString = try container.decode(String.self, forKey: .fallDistance)
            fallDistance = Double(distanceString) ?? 0.0

            let durationString = try container.decode(String.self, forKey: .fallDuration)
            fallDuration = Double(durationString) ?? 0.0
        }
}

struct BalloonInformation: Codable {
    var Balloon : String
    var animation : String
    var animateNum : Int
    
    enum CodingKeys: String, CodingKey {
        case Balloon, animation, animateNum
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        let BalloonString = try container.decode(String.self, forKey: .Balloon)
        Balloon = BalloonString
        
        let animationString = try container.decode(String.self, forKey: .animation)
        animation = animationString

        let animateNumString = try container.decode(String.self, forKey: .animateNum)
        animateNum = Int(animateNumString) ?? 0
        
    }
    
}

struct BackgroundAnimation: Codable {
    var name: String
    var number: Int
    var size: Float

    enum CodingKeys: String, CodingKey {
        case name
        case number
        case size
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        let nameString = try container.decode(String.self, forKey: .name)
        name = nameString

        let numberString = try container.decode(String.self, forKey: .number)
        number = Int(numberString) ?? 0
        
        let sizeString = try container.decode(String.self, forKey: .size)
        size =  Float(sizeString) ?? 0
        
    }
}

struct GameDataJSON: Codable {
    var sceneBackground: [sceneBackground]
    var BalloonInformation: [BalloonInformation]
    var BackgroundAnimation: [BackgroundAnimation]
}


