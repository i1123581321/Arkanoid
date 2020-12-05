//
//  EndScene.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/12/2.
//

import SpriteKit
import GameplayKit

/// 结束场景的委托
protocol EndSceneDelegate:class {
    func restartDidClick(scene:EndScene)
    func menuDidClick(scene:EndScene)
}

class EndScene: SKScene {
    // MARK: Properties
    var buttons = Array<Button>()
    unowned var endSceneDelegate:EndSceneDelegate?
    
    var messageLabel:SKLabelNode!
    var scoreLabel:SKLabelNode!
    
    var score = 0.0 {
        didSet{
            scoreLabel.text = "Your Score: \(round(score))"
        }
    }
    
    // MARK: Methods
    override func sceneDidLoad() {
        self.scaleMode = .aspectFit
        
        let restartButton = self.childNode(withName: "//restartButton") as! Button
        restartButton.buttonDidTouched = {self.endSceneDelegate?.restartDidClick(scene: self)}
        let menuButton = self.childNode(withName: "//menuButton") as! Button
        menuButton.buttonDidTouched = {self.endSceneDelegate?.menuDidClick(scene: self)}
        self.messageLabel = self.childNode(withName: "//messageLabel") as! SKLabelNode?
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as! SKLabelNode?
        
        buttons.append(restartButton)
        buttons.append(menuButton)
    }
    
    /**
     根据比赛结果设置信息
     */
    func setMessage(win:Bool){
        if win {
            messageLabel.text = "Congratulation!"
        } else {
            messageLabel.text = "Game Over..."
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        buttons.forEach { button in
            if button.contains(touch.location(in: self)){
                button.touched = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        buttons.forEach { button in
            if button.contains(touch.location(in: self)) && button.touched{
                button.buttonDidTouched?()
            }
            button.touched = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttons.forEach { button in
            button.touched = false
        }
    }
}
