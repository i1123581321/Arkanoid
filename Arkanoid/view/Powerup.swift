//
//  Powerup.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/12/4.
//

import SpriteKit

enum PowerupType: Int {
    case Disruption = 0
    case Enlarge
    case Laser
    case Player
    case Slow
    
    var name:String {
        switch self {
        case .Disruption:
            return "disruption"
        case .Enlarge:
            return "enlarge"
        case .Laser:
            return "laser"
        case .Player:
            return "player"
        case .Slow:
            return "slow"
        }
    }
    
    static func random() -> PowerupType {
        return PowerupType(rawValue: Int(arc4random_uniform(PowerupNum)))!
    }
}

var PowerupAnime = [String:[SKTexture]]()

class Powerup: SKSpriteNode {
    var type:PowerupType
    
    init() {
        type = PowerupType.random()
        var textures = PowerupAnime[type.name]
        if textures == nil {
            let name = type.name
            textures = (1...8).map {SKTexture(imageNamed: "\(name)-\($0)")}
            PowerupAnime[type.name] = textures
        }
        super.init(texture: textures![0], color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: textures![0].size())
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.zPosition = 1
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PowerupCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = WallCategory + PaddleCategory
    }
    
    /**
     根据材质产生旋转动画
     */
    func rorate(){
        run(.repeatForever(.animate(with: PowerupAnime[type.name]!, timePerFrame: 0.2)))
    }
    
    /**
     向下掉落
     */
    func drop(){
        self.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -3.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var powerup:((_ type:PowerupType)->Void)?
}
