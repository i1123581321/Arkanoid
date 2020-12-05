//
//  MenuScene.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/24.
//

import SpriteKit
import GameplayKit

/// 菜单场景的委托
protocol MenuSceneDelegate: class {
    func startDidClick(scene: MenuScene)
    func endlessDidClick(scene: MenuScene)
    func godDidClick(scene: MenuScene)
    func randomDidClick(scene: MenuScene)
}

class MenuScene: SKScene {
    // MARK: Properties
    var buttons = Array<Button>()
    
    unowned var menuSceneDelegate:MenuSceneDelegate?
    
    // MARK: Methods
    override func sceneDidLoad() {
        self.scaleMode = .aspectFit
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = WallCategory
        
        let startButton = self.childNode(withName: "//startButton") as! Button
        startButton.buttonDidTouched = {self.menuSceneDelegate?.startDidClick(scene: self)}
        let endlessButton = self.childNode(withName: "//endlessButton") as! Button
        endlessButton.buttonDidTouched = {self.menuSceneDelegate?.endlessDidClick(scene: self)}
        let godButton = self.childNode(withName: "//godButton") as! Button
        godButton.buttonDidTouched = {self.menuSceneDelegate?.godDidClick(scene: self)}
        let randomButton  = self.childNode(withName: "//randomButton") as! Button
        randomButton.buttonDidTouched = {
            let label = randomButton.children[0] as! SKLabelNode
            if label.text!.hasSuffix("On"){
                label.text = "Random: Off"
            } else {
                label.text = "Random: On"
            }
            self.menuSceneDelegate?.randomDidClick(scene: self)
        }
        
        buttons.append(startButton)
        buttons.append(endlessButton)
        buttons.append(godButton)
        buttons.append(randomButton)
        
        let ball = Ball()
        self.addChild(ball)
        ball.emit()
    }
    
    override func didMove(to view: SKView) {
        
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
