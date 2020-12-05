//
//  Arkanoid.swift
//  Arkanoid
//
//  Created by 钱正轩 on 2020/12/1.
//

import Foundation

/// 打砖块游戏的委托
protocol ArkanoidDelegate: class {
    func gameDidWin(arkanoid: Arkanoid)
    func gameDidLose(arkanoid:Arkanoid)
    func gameDidBegin(arkanoid: Arkanoid)
    func lifeDidLoss(arkanoid: Arkanoid)
    func scoreDidUpdate(arkanoid: Arkanoid)
}

/**
 打砖块的模式
 - 正常：正常的打砖块
 - 无尽：清空砖块后游戏并不结束而是再次刷新新的砖块
 - 上帝模式：当所有小球消失后游戏不是失败而是再次刷新三个小球
 */
enum ArkanoidMode{
    case Normal
    case Endless
    case God
}

class Arkanoid {
    // MARK: Properties
    var score = BasicScore
    var blockNum = 0
    var ballNum = 1
    var life = 3
    var totalScore = 0.0
    var mode = ArkanoidMode.Normal
    var gameStart = false
    unowned var delegate:ArkanoidDelegate?
    
    init() {
        
    }
    
    // MARK: Methods
    /**
     开始游戏时调用
     - parameter withBlock: 砖块数量
     */
    func beginGame(withBlock:Int){
        blockNum = withBlock
        ballNum = (mode == .God) ?  3 : 1
        score = BasicScore
        if !gameStart{
            life = 3
            totalScore = 0.0
        }
        gameStart = true
        delegate?.gameDidBegin(arkanoid: self)
    }
    
    /**
     当小球碰到板时调用
     */
    func hitPaddle(){
        score = BasicScore
    }
    
    /**
     当砖块消失时调用
     */
    func removeBlock(){
        blockNum -= 1
        totalScore += score
        score *= ScoreMultiplier
        delegate?.scoreDidUpdate(arkanoid: self)
        if blockNum == 0 {
            gameStart = false
            delegate?.gameDidWin(arkanoid: self)
        }
    }
    
    /**
     当小球消失时调用
     */
    func removeBall(){
        ballNum -= 1
        if ballNum == 0 {
            switch mode {
            case .God:
                ballNum = 3
                delegate?.gameDidBegin(arkanoid: self)
            default:
                removeLife()
            }
        }
    }
    
    /**
     当球的数量增加时调用
     */
    func addBall(){
        ballNum += 1
    }
    
    /**
     当生命的数量增加时调用
     */
    func addLife(){
        life += 1
    }
    
    /**
     当生命减少时调用
     */
    func removeLife() {
        life -= 1
        if life == 0 {
            gameStart = false
            delegate?.gameDidLose(arkanoid: self)
        } else {
            ballNum = 1
            delegate?.lifeDidLoss(arkanoid: self)
        }
    }
}
