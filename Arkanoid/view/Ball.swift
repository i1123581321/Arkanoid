//
//  Ball.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/23.
//

import SpriteKit

let BallTexture = SKTexture(imageNamed: "ball")
let Emitter = SKEmitterNode(fileNamed: "Boom")!

class Ball: SKSpriteNode {
    
    init(){
        super.init(texture: BallTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: BallTexture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(BallRadius))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.angularDamping = 0.0
        self.physicsBody?.categoryBitMask = BallCategory
        self.physicsBody?.collisionBitMask = BlockCategory + BallCategory + PaddleCategory + WallCategory
        self.physicsBody?.contactTestBitMask = BlockCategory + PaddleCategory + WallCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     在指定位置以指定力发射小球
     */
    func emit(angle:CGVector = random(), x:CGFloat = CGFloat(0.0)){
        self.position = CGPoint(x: x, y: 0.0)
        self.physicsBody?.applyImpulse(angle)
    }
    
    /**
     使球加速
     */
    func speedUp(){
        if let velocity = self.physicsBody?.velocity {
            let accelerator = CGVector(dx: velocity.dx * AccelerateMultiplier, dy: velocity.dy * AccelerateMultiplier)
            self.physicsBody?.applyImpulse(accelerator)
        }
    }
    
    /**
     使球减速
     */
    func slowDown(){
        if let velocity = self.physicsBody?.velocity{
            let accelerator = CGVector(dx: velocity.dx * AccelerateMultiplier * -10.0, dy: velocity.dy * AccelerateMultiplier * -10.0)
            self.physicsBody?.applyImpulse(accelerator)
        }
    }
    
    /**
     生成固定长度但是方向随机的向量
     */
    static private func random() -> CGVector{
        let rad = Double(arc4random_uniform(120) + 30) / 180.0 * Double.pi
        let x = cos(rad) * BallSpeed
        let y = sin(rad) * BallSpeed
        return CGVector(dx: x, dy: y)
    }
}
