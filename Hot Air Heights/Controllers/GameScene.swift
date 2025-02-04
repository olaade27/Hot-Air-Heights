//
//  GameScene.swift
//  Hot Air Heights
//
//  Created by Ola Adeoba on 2024-08-05.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var miles = 0;
    private var userBalloonPick: Int = 0;
    var GameData: GameDataJSON? = nil
    
    private var Balloon: SKSpriteNode!
    private var voidNode: SKSpriteNode!
    var smokeNodes: [SKSpriteNode] = []
    var firstTouch = false
    private let numOfBackground : Int = 13
    private let StartNumOfBackground : Int = 6
    private var holdTask: DispatchWorkItem?
    
    private var lastFrameTime : CFTimeInterval = 0
    private var deltaTime : CFTimeInterval = 0
    private let KBackgroundSpeed: CGFloat = 390.0
    var backgroundItem = [SKSpriteNode?](repeating: nil, count: 13)
    var startBackgroundItem = [SKSpriteNode?](repeating: nil, count: 13)
    
    private var smokeUpFrames:[SKTexture]!
    private var collisionExpFrame: [SKTexture]!
    private var voidFrames:[SKTexture]!
    private var cloudFrames:[SKTexture]!
    
    var checkposition : CGFloat = -1.0
    var direction: CGFloat = 0.0
    var smokedirect: CGFloat = 0.0
    let bottomy: CGFloat = -565
    
    private var isHoldingTouch: Bool = false
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    
    var voidNum : CGFloat = 10.0
    var forward = false
    
    private var backgroundBottom : SKSpriteNode!
    private var backgroundBottomScene: SKSpriteNode!
    private var backgroundTop : SKSpriteNode!
    
    /*
     var scenebackground = [
        Background(background: ["skyhigh_enhanced.jpeg", "3d-fantasy-scene copy.jpg"], scene: SceneItems(currency: SKSpriteNode(), Pickupitems: [SKSpriteNode()], BackgoundItems: [SKSpriteNode(imageNamed: "cloudRend.png")], colisionItems: [SKSpriteNode()])),
        Background(background: ["another_background.jpeg", "fantasy_world.jpg"], scene: SceneItems(currency: SKSpriteNode(), Pickupitems: [SKSpriteNode()], BackgoundItems: [SKSpriteNode()], colisionItems: [SKSpriteNode()]))
    ]
    
    var userBalloon = [
        
    
    ]
    */
    
    func loadJSON() -> GameDataJSON?{
        
        guard let fileURL = Bundle.main.url(forResource: "backgroundDB", withExtension: "json") else {
                print("Error: JSON file not found")
                return nil
            }
        
        do{
            let data = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            
            let backgrounds = try decoder.decode(GameDataJSON.self,from: data)
            
            return backgrounds
            
        } catch {
            
            print("Error decoding JSON: \(error)")
            return nil
            
        }
        
    }

    override func sceneDidLoad() {

        self.lastUpdateTime = 0
       
    }
    
    override func didMove(to View : SKView){
        
        guard GameData != nil else {
               print("GameData failed to load")
               return
        }
           
        self.initializeParallaxEffect()
        self.initializeMainCharacter()
        self.initializeAnimations()
        self.BackgroundItemGenerate()
        self.collisonAnimationVoid()
        
    }
    func GenerateRandomPosition() -> [Double]{
        
        let start = frame.minX
        let x = Double.random(in: start...frame.maxX)
        let y = Double.random(in: frame.maxY+10...frame.maxY+backgroundBottomScene.size.height)
        let value = [x,y]
        return value
        
    }
    func GenerateRandomSize() -> [Double]{
        
        let width = Double.random(in: 500.0...700.0)
        
        let height = Double.random(in: 100.0...500.0)
        
        let value = [width, height]
        
        return value
    }
    func BackgroundItemGenerate(){
        
        guard let originalItem = GameData!.sceneBackground[miles].scene.BackgroundItems?[0].name else {return}
        
        for index in (0..<StartNumOfBackground){
            let startBackgroundItemNode  = SKSpriteNode(imageNamed: originalItem)
            let startSize = GenerateRandomSize()
            startBackgroundItemNode.size = CGSize(width: startSize[0], height: startSize[1])
            startBackgroundItemNode.zPosition = 0
            let startSum = GenerateRandomPosition()
            startBackgroundItemNode.position = CGPoint(x: startSum[0] , y: frame.maxY)
            startBackgroundItem[index] = startBackgroundItemNode
            addChild(startBackgroundItemNode);
            
            
        }
        for index in (0..<numOfBackground){
            
            let backgroundItemNode = SKSpriteNode(imageNamed: originalItem)
            let size = GenerateRandomSize()
            backgroundItemNode.size = CGSize(width: size[0], height: size[1])
            backgroundItemNode.zPosition = 0
            let sum = GenerateRandomPosition()
            backgroundItemNode.position = CGPoint(x: sum[0] , y: sum[1])
            backgroundItem[index] = backgroundItemNode;
            addChild(backgroundItemNode);
            
        }

    }//start
    func initializeMainCharacter(){
        let balloonString = GameData!.BalloonInformation[userBalloonPick].Balloon
        Balloon = SKSpriteNode(imageNamed: balloonString)
        Balloon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        Balloon.size = CGSize(width: Balloon.size.width / 4, height: Balloon.size.height / 4)
        Balloon.position = CGPoint(x:0.0, y: -540 + Balloon.size.height)
        Balloon.zPosition = 1
        addChild(Balloon)
        
    }
    
    
    func initializeAnimations() {
        
        let currentBallonAnimation = [
            GameData!.BalloonInformation[userBalloonPick].animation,
            GameData!.BackgroundAnimation[0].name,
            GameData!.BackgroundAnimation[1].name
        ]
        let currentBallonAnimationTime = [
            GameData!.BalloonInformation[userBalloonPick].animateNum,
            GameData!.BackgroundAnimation[0].number,
            GameData!.BackgroundAnimation[1].number
            
        ]
        
        let animationsAtlas = SKTextureAtlas(named: "AnimationArt")
        var x: Int = 0;
        
        
        for numTime in currentBallonAnimationTime {
            var auxFrames = [SKTexture]()
            for i in 0..<numTime+1 {
                let textureName = String(format: currentBallonAnimation[x], i)
                let texture = animationsAtlas.textureNamed(textureName)
                auxFrames.append(texture)
            }
            
            switch x {
                   case 0:
                       smokeUpFrames = auxFrames
                   case 1:
                       collisionExpFrame = auxFrames
                   case 2:
                       voidFrames = auxFrames
                   default:
                break;
            }
        
            x+=1;
        }
        
    }

    func tappedAnimation() {
        if let smokeUpFrames = smokeUpFrames, !smokeUpFrames.isEmpty {
                // Create a new SKSpriteNode for the smoke animation
                let smokeNode = SKSpriteNode(texture: smokeUpFrames.first)
                smokeNode.position = CGPoint(x: Balloon.position.x, y: Balloon.position.y - Balloon.size.height / 2) // Adjust the position as needed
                smokeNode.zPosition = 1 // Ensure smoke is above other elements
                addChild(smokeNode)
                
                // Run the smoke animation on the new node
                let animateSmoke = SKAction.animate(with: smokeUpFrames, timePerFrame: 0.1) // Adjust duration as needed
                let removeAction = SKAction.removeFromParent()
                smokeNode.run(SKAction.sequence([animateSmoke, removeAction]), withKey: "smokeAnimation")
            }
    }
    
    func collisonAnimationVoid(){
       // let voidSize = GameData!.BackgroundAnimation[1].size
        if let void = voidFrames, !voidFrames.isEmpty {
            voidNode = SKSpriteNode(texture: void.first)
            voidNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            voidNode.size = CGSize(width: 0.0, height: 0.0)
            voidNode.position = CGPoint(x: self.frame.maxX - voidNode.size.width, y: -540 + Balloon.size.height)
            voidNode.zPosition = 2
            
            addChild(voidNode)
            
            let voidAnimate = SKAction.animate(with: voidFrames, timePerFrame: 0.1)
            
            let repeatAction = SKAction.repeatForever(voidAnimate)
            voidNode.run(repeatAction, withKey: "voidAnimation")
            
            
            
        }
    }
    func voidExpand(_ cont : Bool) {
        // Increment the size as needed.
        if(isHoldingTouch == false){
            if voidNode.size.height < Double(GameData!.BackgroundAnimation[1].size) {
                voidNum += 5.0
                let voidHeight = voidNum
                voidNode.size.height = voidHeight
            }
            
        } else if cont {
            if(voidNode.size.height > 0.0){
                voidNum -= 5.0
                let voidHeight = voidNum
                voidNode.size.height = voidHeight
            }
        }
        
    }
    func moveVoid() {

        let centerX = self.frame.midX
        let centerY = self.frame.midY
        
        // Move the voidNode to the center
        let moveToCenter = SKAction.move(to: CGPoint(x: centerX, y: ), duration: 1.0) // 1-second animation
        
        // Increase the size gradually
        let increaseSize = SKAction.resize(byWidth: 10.0, height: 10.0, duration: 1.0) // Increase size over 1 second
        
        // Group the actions to run them simultaneously
        let moveAndResize = SKAction.group([moveToCenter, increaseSize])
        
        // Run the combined action
        voidNode.run(moveAndResize)
    }
    func initializeParallaxEffect(){
        
        let startCurrentBackground = GameData!.sceneBackground[miles].background[1]
        let currentBackground = GameData!.sceneBackground[miles].background[0]
        
        backgroundBottom = SKSpriteNode(imageNamed: startCurrentBackground)
        backgroundBottom.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundBottom.position = CGPoint(x: 0.0, y: 0.0)
        backgroundBottom.size = self.size
        backgroundBottom.zPosition = -1
        
        
        //change with loop after for each level
        backgroundBottomScene = SKSpriteNode(imageNamed: currentBackground)
        backgroundBottomScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundBottomScene.position = CGPoint(x: 0.0, y: 0.0)
        backgroundBottomScene.size = self.size
        backgroundBottomScene.zPosition = -1
        
        backgroundBottomScene.position = CGPoint(x: backgroundBottom.position.x, y: backgroundBottom.position.y + backgroundBottom.size.height)
        
        backgroundBottomScene.run(SKAction.rotate(byAngle: CGFloat.pi, duration: 0))
        
        
        backgroundTop = (backgroundBottomScene.copy() as! SKSpriteNode)
        backgroundTop.position = CGPoint(x: backgroundBottomScene.position.x, y: backgroundBottomScene.position.y + backgroundBottomScene.size.height)
        
        backgroundTop.run(SKAction.rotate(byAngle: CGFloat.pi, duration: 0))
        
        addChild(backgroundBottom)
        addChild(backgroundBottomScene)
        addChild(backgroundTop)
    }
    
    func updateParallaxLayers(currentTime : CFTimeInterval){
        
        if lastFrameTime <= 0 {
            lastFrameTime = currentTime
        }
        deltaTime = currentTime - lastFrameTime
        
        lastFrameTime = currentTime
        
        if isHoldingTouch == true{
            self.moveParallaxLayer(currentLayer : backgroundBottom, bottomLayer: backgroundBottomScene, topLayer : backgroundTop, speed: KBackgroundSpeed)
        } else{
            //voidExpand(forward)
            moveBackItemX(speed)
        }
        
    }
    
    
    func moveParallaxLayer(currentLayer : SKSpriteNode, bottomLayer : SKSpriteNode, topLayer: SKSpriteNode, speed : CGFloat) -> Void {
        
            for parallaxLayer in [bottomLayer,topLayer]{
                
                var nextPosition = parallaxLayer.position
                
                nextPosition.y -= CGFloat(speed * CGFloat(deltaTime))
        
                parallaxLayer.position = nextPosition
                
                if(currentLayer.frame.maxY < self.frame.minY){
                    moveBackItem(speed, parallaxLayer)
                }
                
                
                
                if parallaxLayer.frame.maxY < self.frame.minY {
                    parallaxLayer.position = CGPoint(x: parallaxLayer.position.x, y: parallaxLayer.position.y + parallaxLayer.size.height * 2)
                }
                
            }
            if(currentLayer.position.y < self.frame.minY){
                forward = true
            }
            currentLayer.position.y -= CGFloat(speed  * CGFloat(deltaTime))
            moveStartBackItem(speed)
            //voidExpand(forward)
           
    }
    
    func  moveStartBackItem(_ speed : CGFloat){
        for index in (0..<StartNumOfBackground){
            
            guard let backgroundItem = startBackgroundItem[index] else { return }
            
            backgroundItem.position.y -= (speed * CGFloat(deltaTime))
            
        }
    }
    func  moveBackItem(_ speed : CGFloat, _ Layer : SKSpriteNode){
        
        for index in (0..<numOfBackground){
            
            guard let backgroundItem = backgroundItem[index] else { return }
            
            if isHoldingTouch == true{
                backgroundItem.position.y -= (speed * CGFloat(deltaTime))
            }
            
            if  backgroundItem.position.y < frame.minY {
                let size = GenerateRandomSize()
                backgroundItem.size = CGSize(width: size[0], height: size[1])
                let sum = GenerateRandomPosition()
                backgroundItem.position.y = sum[1]
                backgroundItem.position.x = sum[0]
            } else if backgroundItem.position.y > frame.maxY + 50 && isHoldingTouch == true {}
            
            
        }
    }
    func  moveBackItemX(_ speed : CGFloat){
        
        for index in (0..<numOfBackground){
            
            guard let backgroundItem = backgroundItem[index] else { return }
            
            if isHoldingTouch == false{
                backgroundItem.position.x -= 0.2
            }
            
           if  backgroundItem.position.x < frame.minX {
               // let size = GenerateRandomSize()
                //backgroundItem.size = CGSize(width: size[0], height: size[1])
              //  let sum = GenerateRandomPosition()
               // backgroundItem.position.y = sum[1]
               // backgroundItem.position.x = sum[0]
           } else if backgroundItem.position.x > frame.maxX + 50 && isHoldingTouch == false {
               
               
           }
            
        }
    }
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        firstTouch = true
        holdTask?.cancel()
        isHoldingTouch = true
        if let touch = touches.first {
            if Balloon.hasActions(){
                Balloon.removeAllActions()
                stopBalloonFall()
                
            }
            let location = touch.location(in: self)
            self.moveBalloonToNextLocationY(touchLocation: location)
            moveVoid()
        }
    }
    
    func moveBalloonToNextLocationY(touchLocation: CGPoint) {
        
        let BalloonSpeed: CGFloat = 300.0
        
        var duration: CGFloat = 0.0
        
        var nextPosition : CGPoint
        
        nextPosition = CGPoint(
            x: smokedirect,
            y: Balloon.position.y + 130
        )
        checkposition = nextPosition.y
        
         duration = self.distanceBetween(point: Balloon.position, andPoint: nextPosition) / BalloonSpeed
        
        let moveAction = SKAction.moveTo(y: nextPosition.y, duration: Double(duration))
        Balloon.run(moveAction)
        BalloonFall()
        tappedAnimation()
        
    }
    func moveBalloonToNextLocationX(touchLocation: CGPoint) {
        let BalloonSpeed: CGFloat = 300.0
        var nextPosition = Balloon.position
        
        var duration: CGFloat = 0.0
        var moveAction: SKAction!
        

        if checkposition > bottomy + Balloon.size.height + 130 {
                // Move right
                nextPosition = CGPoint(x: touchLocation.x, y: Balloon.position.y)
                
                duration = self.distanceBetween(point: Balloon.position , andPoint: nextPosition) / BalloonSpeed
                moveAction = SKAction.moveTo(x: nextPosition.x, duration: Double(duration))
           
            Balloon.run(moveAction)
            BalloonFall()
            smokedirect = nextPosition.x
        }
    }
    var fallAction: SKAction?

    func BalloonFall() {
        // Define the falling action
        let fallDistance: CGFloat = -20.0
        let fallDuration: TimeInterval = 0.1 // Adjust the duration as needed

        // Create the action to move the balloon down by fallDistance
        let fall = SKAction.moveBy(x: 0, y: fallDistance, duration: fallDuration)
        
        // Create a repeating action that continuously falls
        let repeatFall = SKAction.repeatForever(fall)
        
        // If there's already a falling action, remove it before adding a new one
        Balloon.removeAction(forKey: "falling")
        
        // Run the repeating fall action
        Balloon.run(repeatFall, withKey: "falling")
    }

    func stopBalloonFall() {
        // Stop the falling action
        Balloon.removeAction(forKey: "falling")
    }


    func distanceBetween(point p1:CGPoint, andPoint p2:CGPoint) -> CGFloat {
        return sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2))
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if Balloon.hasActions(){
                Balloon.removeAllActions()
                
            }
            let finalLocation = t.location(in: self)
            moveBalloonToNextLocationX(touchLocation: finalLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        holdTask = DispatchWorkItem {
            self.isHoldingTouch = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: holdTask!)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        if firstTouch == true{
            self.updateParallaxLayers(currentTime: currentTime)
        }
    }
    override func didEvaluateActions() {
        
    }
    override func didSimulatePhysics() {
    
    }
}


