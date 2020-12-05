//
//  GameViewController.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
    let menuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
    let endScene = SKScene(fileNamed: "EndScene") as! EndScene
    let arkanoid = Arkanoid()
    
    let flipTrans = SKTransition.flipVertical(withDuration: 2.0)
    let fadeTrans = SKTransition.crossFade(withDuration: 2.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuScene.menuSceneDelegate = self
        gameScene.gameSceneDelegate = self
        endScene.endSceneDelegate = self
        arkanoid.delegate = self
        
        flipTrans.pausesOutgoingScene = false
        flipTrans.pausesIncomingScene = true
        
        fadeTrans.pausesOutgoingScene = true
        
        guard let view = self.view as! SKView? else {
            fatalError("view type error")
        }
        
        
        print(view.bounds.size)
        view.presentScene(menuScene)
        view.showsFPS = true
        view.showsNodeCount = true
    }
    
    /**
     加载场景
     */
    func moveTo(_ scene: SKScene, transition:SKTransition){
        guard let view = self.view as! SKView? else {
            fatalError("view type error")
        }
        view.presentScene(scene, transition: transition)
    }
}

extension GameViewController:EndSceneDelegate {
    func restartDidClick(scene: EndScene) {
        moveTo(gameScene, transition: flipTrans)
    }
    
    func menuDidClick(scene: EndScene) {
        moveTo(menuScene, transition: flipTrans)
    }
}

extension GameViewController:MenuSceneDelegate {
    func startDidClick(scene: MenuScene) {
        arkanoid.mode = .Normal
        moveTo(gameScene, transition: flipTrans)
    }
    
    func endlessDidClick(scene: MenuScene) {
        arkanoid.mode = .Endless
        moveTo(gameScene, transition: flipTrans)
    }
    
    func godDidClick(scene: MenuScene) {
        arkanoid.mode = .God
        moveTo(gameScene, transition: flipTrans)
    }
    
    func randomDidClick(scene: MenuScene) {
        gameScene.random = !gameScene.random
    }
}


extension GameViewController: GameSceneDelegate {
    func disruptionDidGet(scene: GameScene) {
        arkanoid.addBall()
        arkanoid.addBall()
    }
    
    func playerDidGet(scene: GameScene) {
        arkanoid.addLife()
        scene.life = arkanoid.life
    }
    
    func blockDidSetUp(scene: GameScene) {
        arkanoid.beginGame(withBlock: scene.blockNum)
    }
    
    func blockDidRemove(scene: GameScene) {
        arkanoid.removeBlock()
    }
    
    func ballDidRemove(scene: GameScene) {
        arkanoid.removeBall()
    }
    
    func ballDidHitPaddle(scene: GameScene) {
        arkanoid.hitPaddle()
    }
}

extension GameViewController: ArkanoidDelegate {
    func scoreDidUpdate(arkanoid: Arkanoid) {
        gameScene.score = arkanoid.totalScore
    }
    
    func gameDidWin(arkanoid: Arkanoid) {
        if arkanoid.mode == .Endless {
            gameScene.setUp()
        } else {
            endScene.setMessage(win: true)
            endScene.score = arkanoid.totalScore
            moveTo(endScene, transition: fadeTrans)
        }
    }
    
    func gameDidLose(arkanoid: Arkanoid) {
        endScene.setMessage(win: false)
        endScene.score = arkanoid.totalScore
        moveTo(endScene, transition: fadeTrans)
    }
    
    func gameDidBegin(arkanoid: Arkanoid) {
        gameScene.score = arkanoid.totalScore
        gameScene.life = arkanoid.life
        for _ in 0..<arkanoid.ballNum {
            gameScene.emitBall()
        }
    }
    
    func lifeDidLoss(arkanoid: Arkanoid) {
        gameScene.removePaddle {
            self.gameScene.resetPaddle {
                for _ in 0..<arkanoid.ballNum {
                    self.gameScene.life = arkanoid.life
                    self.gameScene.emitBall()
                }
            }
        }
    }
}
