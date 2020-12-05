//
//  Laser.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/12/5.
//

import SpriteKit

let LaserTexture = SKTexture(imageNamed: "laser")

class Laser: SKSpriteNode {
    init(){
        super.init(texture: LaserTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: LaserTexture.size())
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = LaserCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BlockCategory
    }
    
    /**
     在指定位置发射激光
     */
    func emit(x:CGFloat){
        self.position.x = x
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: BallSpeed))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
