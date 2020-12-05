//
//  Paddle.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/23.
//

import SpriteKit

let PaddleTexture = SKTexture(imageNamed: "paddle")
let LongPaddleTexture = SKTexture(imageNamed: "paddle-long")
let LaserPaddleTexture = SKTexture(imageNamed: "paddle-laser")
let LaserPaddleAnime = (1...8).map {SKTexture(imageNamed: "paddle-laser-\($0)")}
let PaddleAnime = (1...5).map { SKTexture(imageNamed: "paddle-\($0)")}

enum PaddleType {
    case Normal
    case Long
    case Laser
}


class Paddle: SKSpriteNode {
    let type:PaddleType
    
    init(type:PaddleType = .Normal){
        self.type = type
        switch type{
        case .Normal:
            super.init(texture: PaddleAnime[0], color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: PaddleTexture.size())
        case .Long:
            super.init(texture: LongPaddleTexture, color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: LongPaddleTexture.size())
        case .Laser:
            super.init(texture: LaserPaddleAnime[0], color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), size: LaserPaddleTexture.size())
        }
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PaddleCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     加载动画
     */
    func load(_ completion: @escaping ()-> Void){
        switch type {
        case .Normal:
            run(.animate(with: PaddleAnime + [PaddleTexture], timePerFrame: paddleInterval), completion: completion)
        case .Laser:
            run(.animate(with: LaserPaddleAnime + [LaserPaddleTexture], timePerFrame: paddleInterval / 2), completion: completion)
        case .Long:
            return
        }
    }
    
    /**
     移动板
     */
    func move(to:CGFloat){
        if(to < 375 - self.size.width / 2 && to > -375 + self.size.width / 2){
            self.position.x = to
        }
    }
}
