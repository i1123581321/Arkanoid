//
//  BlockGrid.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/23.
//

import SpriteKit

let blockColors = ["blue", "cyan", "green", "magenta", "orange", "red", "white", "yellow"]
var blockTextures = Dictionary<String, SKTexture>();


class BlockGrid:SKNode {
    
    var blockNum = 0
    
    init(random:Bool = false){
        super.init()
        blockNum = 0
        if random {
            let f1 = ASCII_FONT.randomElement()!
            let f2 = ASCII_FONT.randomElement()!
            generateWithFont(font: f1, base: 0)
            generateWithFont(font: f2, base: 7)
        } else {
            for row in 0..<BlockRow{
                for col in 0..<BlockColumn {
                    self.addChild(generateBlock(row: row, col: col))
                    blockNum += 1
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     根据字模信息生成砖块
    - parameter font: 字模，长度为12的8bit信息
    - parameter base: 基准列
     */
    func generateWithFont(font:[Int], base:Int){
        let colBegin = base
        let colEnd = base + BlockColumn / 2
        
        for row in 0..<2 {
            for col in colBegin..<colEnd {
                self.addChild(generateBlock(row: row, col: col))
                blockNum += 1
            }
        }
        for row in 2..<14 {
            var i = font[13 - row]
            for col in colBegin..<colEnd{
                let j = i & 0x1
                if j != 0 {
                    self.addChild(generateBlock(row: row, col: col))
                    blockNum += 1
                }
                i = i >> 1
            }
        }
        for row in 14..<BlockRow{
            for col in colBegin..<colEnd {
                self.addChild(generateBlock(row: row, col: col))
                blockNum += 1
            }
        }
    }
    
    /**
     在对应位置生成砖块的 node
     */
    func generateBlock(row:Int, col:Int) -> SKSpriteNode {
        let color = blockColors.randomElement()!
        var texture = blockTextures[color]
        if texture == nil {
            texture = SKTexture(imageNamed: color)
            blockTextures[color] = texture
        }
        let sprite = SKSpriteNode(texture: texture)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = false
        sprite.physicsBody?.friction = 0.0
        sprite.physicsBody?.categoryBitMask = BlockCategory
        
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        sprite.position = CGPoint(x: col * BlockWidth, y: row * BlockHeight)
        sprite.alpha = 0.0
        return sprite
    }
    
    /**
     随机 fade-in
     */
    func show(_ completion: @escaping () -> Void){
        var maxDuration:TimeInterval = 0;
        self.children.forEach{ block in
            let time = TimeInterval(Double(arc4random_uniform(2000)) / 1000)
            block.run(SKAction.sequence([.wait(forDuration: time), .fadeIn(withDuration: fadeInDuration)]))
            maxDuration = max(maxDuration, time + fadeInDuration)
        }
        run(.wait(forDuration: maxDuration), completion: completion)
    }
}
