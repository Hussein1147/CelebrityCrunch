import SpriteKit
import UIKit // For UIColor

// Assuming RWTActor and RWTLevel are already Swift classes from previous migrations.

@objc public protocol GameSceneDelegate: NSObjectProtocol {
    func startMatching()
}

@objc(GameScene)
public class GameScene: SKScene {

    @objc public var level: RWTLevel?
    @objc weak public var delegate: GameSceneDelegate? // Custom delegate

    // For GameViewController to know which actor was tapped
    @objc public var actorColumn: Int = 0
    @objc public var actorRow: Int = 0

    // Private properties for layers and sprites
    // Using implicitly unwrapped optionals for nodes that are set up in init and expected to exist.
    private var gameLayer: SKNode!
    private var actorLayer: SKNode!
    private var tilesLayer: SKNode!
    private var selectionSprite: SKSpriteNode!
    // chosenSprite was in Obj-C but not obviously used; will omit unless a usage is found during method migration.

    // Constants
    static let TileWidth: CGFloat = 64.0
    static let TileHeight: CGFloat = 95.0

    // Initializers
    override public init(size: CGSize) {
        super.init(size: size)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let background = SKSpriteNode(color: colorWithHexString(hex: "FF6666"), size: UIScreen.main.bounds.size)
        self.addChild(background)

        self.gameLayer = SKNode()
        self.gameLayer.isHidden = true // Will be animated in
        self.addChild(self.gameLayer)
        
        // Calculate layer position based on NumColumns/NumRows from RWTLevel (Swift version)
        // Using RWTLevel.NumColumns and RWTLevel.NumRows for clarity.
        let layerPosition = CGPoint(
            x: -GameScene.TileWidth * CGFloat(RWTLevel.NumColumns) / 2.0,
            y: -GameScene.TileHeight * CGFloat(RWTLevel.NumRows) + self.size.height / 4.0 + (GameScene.TileWidth / 10.0)
        )
        
        self.actorLayer = SKNode()
        self.actorLayer.position = layerPosition
        
        self.tilesLayer = SKNode()
        self.tilesLayer.position = layerPosition
        
        self.gameLayer.addChild(self.tilesLayer)
        self.gameLayer.addChild(self.actorLayer)
        
        // selectionSprite is initialized but not added to a parent until needed.
        self.selectionSprite = SKSpriteNode() 
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // Standard practice if not using storyboards/nib for scenes
    }

    // --- Color Helper ---
    // (Could be a UIColor extension too)
    public func colorWithHexString(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("0X") {
            cString.remove(at: cString.startIndex)
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // --- Point Conversion ---
    @objc public func point(forColumn column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * GameScene.TileWidth + GameScene.TileWidth / 2.0,
            y: CGFloat(row) * GameScene.TileHeight + GameScene.TileHeight / 2.0
        )
    }

    @objc(convertPoint:toColumn:row:) // Match Obj-C selector for compatibility
    public func convertPoint(_ point: CGPoint, toColumn column: UnsafeMutablePointer<Int>?, row: UnsafeMutablePointer<Int>?) -> Bool {
        guard let columnPtr = column, let rowPtr = row else {
            return false // Pointers must be non-nil
        }

        // Check if the point is within the bounds of the actor layer.
        // Using RWTLevel.NumColumns and RWTLevel.NumRows for grid dimensions.
        if point.x >= 0 && point.x < CGFloat(RWTLevel.NumColumns) * GameScene.TileWidth &&
           point.y >= 0 && point.y < CGFloat(RWTLevel.NumRows) * GameScene.TileHeight {
            
            columnPtr.pointee = Int(point.x / GameScene.TileWidth)
            rowPtr.pointee = Int(point.y / GameScene.TileHeight)
            return true
        } else {
            columnPtr.pointee = NSNotFound // Using standard NSNotFound
            rowPtr.pointee = NSNotFound
            return false
        }
    }

    // --- Touch Handling ---
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self.actorLayer)

        var tappedColumn: Int = NSNotFound
        var tappedRow: Int = NSNotFound
        
        // Use a block to capture the values from the UnsafeMutablePointers
        let found = convertPoint(location, toColumn: &tappedColumn, row: &tappedRow)

        if found {
            if let actor = self.level?.actor(atColumn: tappedColumn, row: tappedRow) {
                self.actorColumn = tappedColumn
                self.actorRow = tappedRow
                
                showBlueSelection(forActor: actor) // Renamed for Swift convention
                self.delegate?.startMatching()
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectionSprite.parent != nil {
            hideSelectionIndicator()
        }
    }
    
    // --- Adding Sprites ---
    @objc public func addTiles() {
        guard let level = self.level else { return }
        for r in 0..<RWTLevel.NumRows {
            for c in 0..<RWTLevel.NumColumns {
                if level.tile(atColumn: c, row: r) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = point(forColumn: c, row: r)
                    self.tilesLayer.addChild(tileNode)
                }
            }
        }
    }

    @objc public func addSprites(forActors actors: Set<RWTActor>) {
        for actor in actors {
            if let spriteName = actor.spriteName() { // RWTActor.spriteName() now returns String?
                let sprite = SKSpriteNode(imageNamed: spriteName)
                sprite.position = point(forColumn: actor.column, row: actor.row)
                self.actorLayer.addChild(sprite)
                actor.sprite = sprite // Assign to RWTActor's sprite property

                // Animation from original
                actor.sprite?.alpha = 0
                actor.sprite?.xScale = 0.5
                actor.sprite?.yScale = 0.5
                actor.sprite?.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                    ])
                ]))
            }
        }
    }
    
    // --- Selection Indicators ---
    @objc public func showSelectionIndicators(forActor actor: RWTActor) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let highlightedSpriteName = actor.highlightedSpriteName(), // RWTActor method
           let texture = try? SKTexture(imageNamed: highlightedSpriteName) { // SKTexture init can throw
            selectionSprite.size = texture.size()
            selectionSprite.run(SKAction.setTexture(texture))
            
            actor.sprite?.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }

    // Renamed from showBlueSelection to follow Swift naming convention for the `forActor` part
    @objc public func showBlueSelection(forActor actor: RWTActor) {
        guard let currentSprite = actor.sprite, let blueSpriteName = actor.blueHighlightedSpriteName() else { return }

        currentSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
        
        let blueSprite = SKSpriteNode(imageNamed: blueSpriteName)
        blueSprite.position = point(forColumn: actor.column, row: actor.row)
        self.actorLayer.addChild(blueSprite)
        actor.sprite = blueSprite // Update actor's sprite reference

        blueSprite.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1, withRange: 0.3), // Original had withRange
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.10)
            ])
        ]))
    }

    @objc public func hideSelectionIndicator() {
        selectionSprite.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // --- Animations ---
    @objc public func animateActorLayer() {
        gameLayer.isHidden = false
        gameLayer.position = CGPoint(x: 0, y: self.size.height)
        let action = SKAction.moveBy(x: 0, y: -self.size.height, duration: 0.7)
        action.timingMode = .easeOut
        gameLayer.run(action)
    }

    @objc(animateMatchedActors:completion:)
    public func animateMatchedActors(_ chains: Set<RWTActor>, completion: @escaping () -> Void) {
        for actor in chains {
            if let sprite = actor.sprite {
                let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                scaleAction.timingMode = .easeOut
                sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]))
                actor.sprite = nil // Clear reference
            }
        }
        // Run completion after a delay
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4), // Original delay
            SKAction.run(completion)
        ]))
    }

    @objc(animateFallingActors:completion:)
    public func animateFallingActors(_ actor: RWTActor, completion: @escaping () -> Void) {
        guard let spriteName = actor.spriteName() else {
            if completion != nil { completion() } // Ensure completion is called
            return
        }

        let sprite = SKSpriteNode(imageNamed: spriteName)
        actor.sprite = sprite // Assign to actor

        let destinationPoint = point(forColumn: actor.column, row: actor.row)
        
        // Start one tile above the grid
        let startY = CGFloat(RWTLevel.NumRows) * GameScene.TileHeight + GameScene.TileHeight / 2.0
        let startPoint = CGPoint(x: destinationPoint.x, y: startY)
        
        sprite.position = startPoint
        self.actorLayer.addChild(sprite)

        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: destinationPoint)
        
        let moveAction = SKAction.follow(path, asOffset: false, orientToPath: false, duration: 0.3)
        moveAction.timingMode = .easeOut
        
        sprite.run(SKAction.sequence([moveAction, SKAction.run(completion)]))
    }

    @objc(shuffleActorsSprites:completion:)
    public func shuffleActorsSprites(_ actors: Set<RWTActor>, completion: @escaping () -> Void) {
        // This method was similar to addSpritesForActors but with a completion block.
        // The animation logic is the same. Assuming completion is for after *all* sprites are added and animated.
        // This might need a dispatch group if completion should wait for all animations.
        // For now, matching Obj-C: completion is run for EACH actor's animation sequence.
        // This is likely not the intended behavior if completion is a finalizer.
        // Let's assume for now it's okay, or that only one actor set is typically shuffled this way.
        
        var actionsToComplete = actors.count
        let groupCompletion = {
            actionsToComplete -= 1
            if actionsToComplete == 0 {
                completion()
            }
        }

        if actors.isEmpty {
            completion()
            return
        }

        for actor in actors {
            if let spriteName = actor.spriteName() {
                let sprite = SKSpriteNode(imageNamed: spriteName)
                sprite.position = point(forColumn: actor.column, row: actor.row)
                self.actorLayer.addChild(sprite)
                actor.sprite = sprite
                
                actor.sprite?.alpha = 0
                actor.sprite?.xScale = 0.5
                actor.sprite?.yScale = 0.5
                actor.sprite?.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                    ]),
                    SKAction.run(groupCompletion) // Run completion for each actor
                ]))
            } else {
                 // If spriteName is nil, still count down for completion.
                groupCompletion()
            }
        }
    }
}
