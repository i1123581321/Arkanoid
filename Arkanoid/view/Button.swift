//
//  Button.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/24.
//

import SpriteKit

class Button: SKSpriteNode {
    
    var buttonDidTouched:(()-> Void)?
    var touched = false
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
