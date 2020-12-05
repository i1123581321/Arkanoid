//
//  GameScene.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/11/21.
//

import SpriteKit
import GameplayKit

/// 游戏场景的委托
protocol GameSceneDelegate: class {
    func blockDidRemove(scene: GameScene)
    func ballDidRemove(scene: GameScene)
    func ballDidHitPaddle(scene: GameScene)
    func blockDidSetUp(scene: GameScene)
    func disruptionDidGet(scene:GameScene)
    func playerDidGet(scene:GameScene)
}

class GameScene: SKScene {
    // MARK: Properties
    var lastUpdateTime:TimeInterval = 0.0
    var accumulator:TimeInterval = 0.0
    var tick:(()->Void)?
    
    var blocksPos:SKNode!
    var ballPos:SKNode!
    var paddlePos:SKNode!
    var scoreLabel:SKLabelNode!
    var lifeLabel:SKLabelNode!
    
    var score = 0.0 {
        didSet{
            self.scoreLabel.text = "Score: \(round(score))"
        }
    }
    
    var life = 0 {
        didSet{
            self.lifeLabel.text = "Life: \(life)"
        }
    }
    
    var paddle:Paddle!{
        didSet{
            if paddle.type == .Laser{
                tick = fire
            } else {
                tick = nil
            }
        }
    }
    
    var blockNum = 0
    var random = false
    
    unowned var gameSceneDelegate:GameSceneDelegate?
    
    // MARK: Methods
    override func sceneDidLoad() {
        self.isUserInteractionEnabled = false
        self.scaleMode = .aspectFit
        self.blocksPos = self.childNode(withName: "//blocksPos")
        self.ballPos = self.childNode(withName: "//ballPos")
        self.paddlePos = self.childNode(withName: "//paddlePos")
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as! SKLabelNode?
        self.lifeLabel = self.childNode(withName: "//lifeLabel") as! SKLabelNode?
        
        // physics settings
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = WallCategory
        
        Powerup.powerup = { [self] type in
            switch type {
            case .Disruption:
                emitBall()
                emitBall()
                gameSceneDelegate?.disruptionDidGet(scene: self)
            case .Enlarge:
                if paddle.type != .Long{
                    let x = paddle.position.x
                    paddle.removeFromParent()
                    paddle = Paddle(type:.Long)
                    paddle.move(to: x)
                    paddlePos.addChild(paddle)
                }
            case .Laser:
                if paddle.type != .Laser{
                    let x = paddle.position.x
                    paddle.removeFromParent()
                    paddle = Paddle.init(type: .Laser)
                    paddle.move(to: x)
                    paddlePos.addChild(paddle)
                    paddle.load {}
                }
            case .Player:
                gameSceneDelegate?.playerDidGet(scene: self)
            case .Slow:
                for child in ballPos.children{
                    let ball = child as! Ball
                    ball.slowDown()
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        print("GameScene move to view")
        self.setUp()
    }
    
    /**
     初始化场景
     */
    func setUp(){
        paddlePos.removeAllChildren()
        ballPos.removeAllChildren()
        blocksPos.removeAllChildren()
        let blockGrid = BlockGrid(random: random)
        blocksPos.addChild(blockGrid)
        blockGrid.show { [self] in
            blockNum = blockGrid.blockNum
            resetPaddle(){
                self.gameSceneDelegate?.blockDidSetUp(scene: self)
            }
        }
    }
    
    /**
     移除板，附带粒子效果
     */
    func removePaddle(completion:@escaping ()->Void){
        removeNodeWithExplode(paddle) {
            self.isUserInteractionEnabled = false
            completion()
        }
    }
    
    /**
     初始化板
     */
    func resetPaddle(_ completion: @escaping () -> Void){
        paddlePos.removeAllChildren()
        paddle = Paddle()
        paddle.move(to: 0.0)
        paddlePos.addChild(paddle)
        paddle.load {
            self.isUserInteractionEnabled = true
            completion()
        }
    }
    
    /**
     发射小球
     */
    func emitBall(){
        let ball = Ball()
        self.ballPos.addChild(ball)
        ball.emit()
    }
    
    /**
     移除节点的同时加上粒子效果
     */
    func removeNodeWithExplode(_ node:SKNode, completion:@escaping ()->Void){
        node.physicsBody = nil
        node.alpha = 0.0
        let emitter = Emitter.copy() as! SKEmitterNode
        emitter.position = node.position
        node.run(.sequence([
            .run {
                node.parent?.addChild(emitter)
                emitter.resetSimulation()
            },
            .wait(forDuration: emitterLifeTime),
            .run {
                emitter.removeFromParent()
                node.removeFromParent()
            }
        ]),completion: completion)
    }
    
    /**
     移除砖块，附带粒子效果，同时有一定几率产生强化
     */
    func removeBlock(contact:SKPhysicsContact){
        if let block = getBody(contact, category: BlockCategory){
            let r = arc4random_uniform(100)
            if r <= PowerupRate{
                let powerup = Powerup()
                powerup.position = block.position
                powerup.rorate()
                block.parent?.addChild(powerup)
                powerup.drop()
            }
            removeNodeWithExplode(block){
                self.gameSceneDelegate?.blockDidRemove(scene: self)
            }
        }
    }
    
    /**
     从 SKPhysicsContact 中根据标示获得对象的 node
     */
    func getBody(_ contact: SKPhysicsContact, category:UInt32) -> SKNode?{
        if contact.bodyA.categoryBitMask == category{
            return contact.bodyA.node
        } else if contact.bodyB.categoryBitMask == category {
            return contact.bodyB.node
        } else {
            return nil
        }
    }
    
    /**
     处理触摸事件，移动板
     */
    func touch(_ touches: Set<UITouch>){
        let touch = touches.first!
        paddle.move(to: touch.location(in: self).x)
    }
    
    /**
     发射激光
     */
    func fire(){
        let l1 = Laser()
        let l2 = Laser()
        paddlePos.addChild(l1)
        paddlePos.addChild(l2)
        l1.emit(x: paddle.position.x + 24)
        l2.emit(x: paddle.position.x - 24)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        accumulator += currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if accumulator > updateInterval{
            tick?()
            accumulator = 0.0
        }
    }
}

/// 处理节点交互和碰撞的 protocol 实现
extension GameScene:SKPhysicsContactDelegate{
    func didBegin(_ contact: SKPhysicsContact) {
        switch contact.bodyA.categoryBitMask + contact.bodyB.categoryBitMask {
        case BallCategory + BlockCategory:
            removeBlock(contact: contact)
            if let ball = getBody(contact, category: BallCategory) as? Ball {
                ball.speedUp()
            }
        case BallCategory + PaddleCategory:
            gameSceneDelegate?.ballDidHitPaddle(scene: self)
        case BallCategory + WallCategory:
            if let ball = getBody(contact, category: BallCategory) {
                if ball.position.y <= paddle.position.y - 12{
                    removeNodeWithExplode(ball){
                        self.gameSceneDelegate?.ballDidRemove(scene: self)
                    }
                }
            }
        case PaddleCategory + PowerupCategory:
            if let powerup = getBody(contact, category: PowerupCategory) as? Powerup{
                Powerup.powerup?(powerup.type)
                powerup.removeFromParent()
            }
        case WallCategory + PowerupCategory:
            getBody(contact, category: PowerupCategory)?.removeFromParent()
        case BlockCategory + LaserCategory:
            getBody(contact, category: LaserCategory)?.removeFromParent()
            removeBlock(contact: contact)
        default:
            return
        }
    }
}
