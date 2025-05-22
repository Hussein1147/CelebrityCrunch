import UIKit
import SpriteKit // For SKView
// Assuming GameScene, RWTLevel are Swift classes.
// GameSceneDelegate is defined in GameScene.swift
// GameViewDelegate was conformed to by RWTLevel in Obj-C. RWTLevel (Swift) now handles this.

// Define GameViewDelegate in Swift if it's not already available via bridging header
// or if it was an informal protocol. For RWTLevel (Swift) to conform, it must be @objc.
// If GameViewController.h (which declared it) is removed, this becomes the source of truth.
@objc public protocol GameViewDelegate: NSObjectProtocol {
    func updateScore() -> Int
}


@objc(GameViewController)
public class GameViewController: UIViewController, GameSceneDelegate, GameViewDelegate {

    // --- IBOutlets ---
    // These need to be connected in the Storyboard/XIB by setting the custom class to
    // "CelebrityCrunch.GameViewController" and re-connecting the outlets.
    // Assuming the SKView is the main view of the controller.
    // If it's a subview, it would be a separate IBOutlet.
    var skView: SKView! {
        return self.view as? SKView
    }

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var movieLabel: UILabel! // Was UITextView in Obj-C, check if UILabel is more appropriate
    @IBOutlet weak var shuffleButton: UIButton!
    
    // gameOverPanel and tapGesture were in Obj-C, but not explicitly in the checklist.
    // Adding them as they are common UI elements for such a game.
    // If they were part of CSAnimationView interaction, that's a separate library.
    @IBOutlet weak var moviePanel: UIImageView! // This was an IBOutlet in Obj-C.
    // tapGestureRecognizer was a property, not an IBOutlet.
    var tapGestureRecognizer: UITapGestureRecognizer!


    // --- Properties ---
    // Game state
    private var score: Int = 0 {
        didSet {
            // Update scoreLabel whenever score changes
            // This simplifies updateLabels()
            scoreLabel?.text = "\(score)"

            // Check for new high-score every time the score changes so we can
            // keep the persisted value in sync and inform the player.
            if score > highScore {
                highScore = score
            }
        }
    }

    // MARK: - High-Score persistence

    /// Key used with `UserDefaults` for persisting the best score between app sessions.
    private let highScoreKey = "CelebrityCrunchHighScoreKey"

    /// The best score achieved on the device across all game sessions. Whenever the
    /// value is increased we write it back to `UserDefaults` so it is automatically
    /// restored the next time the game launches.
    private var highScore: Int = 0 {
        didSet {
            guard oldValue != highScore else { return }

            // Persist the new value
            UserDefaults.standard.set(highScore, forKey: highScoreKey)

            // Visually update an optional high-score label if the developer has
            // added one to the storyboard and hooked it up.
            highScoreLabel?.text = "High-Score: \(highScore)"
        }
    }

    /// Optional outlet that can be added in Interface Builder to show the high-score.
    /// The game will still compile and run even if the label is not connected.
    @IBOutlet private weak var highScoreLabel: UILabel?
    // `movesLeft` was not in the original Obj-C properties, but typical for such games. Omitting for now.

    // Core game components (now Swift versions)
    private var scene: GameScene!
    private var level: RWTLevel!

    // Conformance to GameViewDelegate (from RWTLevel's perspective)
    // This GameViewController will act as the source of truth for the score for RWTLevel.
    // This is a bit circular if RWTLevel also holds score.
    // The original design had RWTLevel holding the score and GameViewController querying it.
    // Let's stick to RWTLevel being the score authority.
    // So, this GameViewController will have a score property primarily for display,
    // and GameViewDelegate's updateScore will fetch from self.level.score.
    public func updateScore() -> Int {
        return self.level?.score ?? 0
    }

    // --- UIViewController Lifecycle ---
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Load high-score from persistent storage before the first game begins so
        // that UI is already up-to-date when we call `updateLabels()` later.
        self.highScore = UserDefaults.standard.integer(forKey: highScoreKey)

        // Initialize score for the fresh game session
        self.score = 0
        
        // Configure the view (SKView)
        // skView is self.view casted. No need for separate IBOutlet if it's the main view.
        skView.isMultipleTouchEnabled = false

        // Create and configure the scene.
        self.scene = GameScene(size: skView.bounds.size)
        self.scene.scaleMode = .aspectFill
        
        // Create the level
        self.level = RWTLevel(firstFilename: "actorTomovie", secondFile: "movieToActor", thirdFile: "Level_0")
        self.scene.level = self.level // Assign level to scene
        
        // Set delegates
        self.scene.delegate = self // GameSceneDelegate
        // self.scoreDelegate = self.level; // In Obj-C, GameViewController's scoreDelegate was RWTLevel.
        // Now, RWTLevel itself implements GameViewDelegate's updateScore.
        // If GameViewController needs to *be* the delegate for RWTLevel (unlikely), it would be self.level.delegate = self.
        // The GameViewDelegate protocol seems designed for RWTLevel to provide score updates.
        // GameViewController's own `updateScore` method will act as the implementation if something needs a GameViewDelegate.
        // This might need clarification if the original scoreDelegate pattern was different.
        // For now, assuming RWTLevel (Swift) has its own score and GameViewController reflects it.

        // Add initial tiles to the scene
        self.scene.addTiles()

        // Present the scene.
        skView.presentScene(self.scene)
        
        // Setup Tap Gesture for moviePanel (if moviePanel exists and is interactive)
        if let moviePanel = self.moviePanel { // Ensure moviePanel IBOutlet is connected
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animateMoviePanelWithShuffle))
            moviePanel.isUserInteractionEnabled = true // UIImageViews are not by default
            moviePanel.addGestureRecognizer(self.tapGestureRecognizer)
        } else {
            print("Warning: moviePanel IBOutlet not connected.")
        }


        // Begin the game
        beginGame()
    }

    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public var shouldAutorotate: Bool {
        return true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    // --- IBActions ---
    @IBAction func shuffleButtonPressed(_ sender: UIButton) {
        // Original Obj-C called [self reShufle];
        // Renaming to Swift convention
        reshuffleBoard()
    }

    // --- GameSceneDelegate Conformance ---
    public func startMatching() {
        // Logic from Obj-C:
        // [self.level chooseActorAtColumn:[self.scene actorColumn] row:[self.scene actorRow]];
        // [self updateScoreLabel];
        // [self handleMatches];
        guard let level = self.level, let scene = self.scene else { return }
        
        level.chooseActor(atColumn: scene.actorColumn, rowInGrid: scene.actorRow) // rowInGrid used for clarity
        updateLabels() // Updates score and potentially other labels
        handleMatches()
    }
    
    // --- Game Logic & UI Updates ---
    private func beginGame() {
        // Original Obj-C logic:
        // UIImage *btnImg = [UIImage imageNamed:@"moviePanel"];
        // [self.moviePanel setImage:btnImg];
        // [self.moviePanel addSubview:self.movieLabel];
        // self.movieLabel.text = [self stringCleanser:self.level.movie.movieName];
        // [self animateMoviePanel];
        // [self showActorLayer];
        // [self shuffle];
        
        // Assuming moviePanel and movieLabel are connected
        self.moviePanel?.image = UIImage(named: "moviePanel")
        // If movieLabel is a subview of moviePanel, ensure it's added in Storyboard/XIB
        // or add it programmatically if needed.
        // self.moviePanel?.addSubview(self.movieLabel) // Only if not already a subview.

        updateLabels() // This will set movieLabel text and score
        animateMoviePanel() // Initial animation of movie panel
        
        self.scene?.animateActorLayer() // Show the game board
        shuffleInitialActors() // Initial population of actors
    }

    // Renamed from Obj-C reShufle
    private func reshuffleBoard() {
        guard let level = self.level, let scene = self.scene else { return }
        
        let actorsToRemove = level.reShuffle() // This clears the level's actor grid and returns actors that were there
        scene.view?.isUserInteractionEnabled = false
        
        // Animate removal of old actors
        scene.animateMatchedActors(actorsToRemove) { [weak self] in
            // After old actors are removed, shuffle new ones in
            let newActors = level.shuffle() // This populates level's grid and returns the set of new actors
            scene.shuffleActorsSprites(newActors) { [weak self] in
                self?.scene.view?.isUserInteractionEnabled = true
            }
        }
    }

    // Renamed from Obj-C shuffle
    private func shuffleInitialActors() {
        guard let level = self.level, let scene = self.scene else { return }
        let newActors = level.shuffle() // Populates level and returns actors
        scene.addSprites(forActors: newActors) // Adds sprites to scene
    }

    private func handleMatches() {
        guard let level = self.level, let scene = self.scene else { return }
        
        let removedActorSet = level.removeMatches() // Removes matched actors from level model, returns them
        
        if !removedActorSet.isEmpty {
            // Provide subtle haptic feedback to acknowledge a successful match on
            // devices that support the Taptic Engine. This improves the tactile
            // feel of the game without affecting devices that lack the hardware.
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            scene.view?.isUserInteractionEnabled = false // Disable interaction during animations
            
            scene.animateMatchedActors(removedActorSet) { [weak self] in
                guard let self = self else { return }
                
                // After matched actors are animated out, fill holes
                let newActors = self.level.fillHoles() // fillHoles now returns Set<RWTActor>
                
                if newActors.isEmpty {
                    self.scene.view?.isUserInteractionEnabled = true // Re-enable if no new actors
                    return
                }

                let dispatchGroup = DispatchGroup()

                for actorToAnimate in newActors {
                    dispatchGroup.enter() // Enter group for each animation
                    self.scene.animateFallingActors(actorToAnimate) {
                        // This completion block is for a single actor's fall.
                        dispatchGroup.leave() // Leave group when this animation is done
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    // This block is executed after all falling animations have completed.
                    self.scene.view?.isUserInteractionEnabled = true
                    // Potentially check for more matches/chain reactions here if game has them
                    // self.handleMatches() // Example: for cascading matches
                }
            }
        } else {
            // If no matches were removed, ensure interaction is enabled (e.g., if it was disabled before this call)
            scene.view?.isUserInteractionEnabled = true
        }
    }

    private func updateLabels() {
        // Update score label
        self.score = self.level?.score ?? 0 // Keep local score in sync
        
        // Update movie label
        if let movieName = self.level?.movie.movieName {
            self.movieLabel?.text = stringCleanser(movieName)
        } else {
            self.movieLabel?.text = ""
        }

        // Update high-score UI (if present)
        highScoreLabel?.text = "High-Score: \(highScore)"
    }
    
    // --- Movie Panel Animation ---
    // This method used CSAnimationView which is a third-party library.
    // For this migration, I'll stub it out or use basic UIView animation if simple.
    // The original also changed the movie and updated label here.
    
    @objc func animateMoviePanelWithShuffle() {
        // Replicates:
        // [self animateMoviePanel];
        // [self reShufle];

        animateMoviePanel() // Animates current panel (or new one if movie changes in animateMoviePanel)
        reshuffleBoard()    // Reshuffles actors for the potentially new movie
    }

    private func animateMoviePanel() {
        guard let moviePanel = self.moviePanel, let level = self.level else { return }

        // Change movie for next panel display
        if let nextMovieName = level.nextLevel() {
            level.movie.movieName = nextMovieName
        }
        updateLabels() // Update movie label with new movie name

        // Basic animation: slide out, change movie, slide in.
        // CSAnimationView provided more complex "bounce" animations.
        // This is a simplified placeholder.
        let originalX = moviePanel.frame.origin.x
        let offscreenX = -moviePanel.frame.width - self.view.frame.width // Move completely off-screen to the left

        UIView.animate(withDuration: 0.3, animations: {
            moviePanel.frame.origin.x = offscreenX
        }) { _ in
            // Update movie name on the label after it's off-screen
            // self.updateLabels() // Already called to set text before animation
            
            // Reset position to the right, then animate in
            moviePanel.frame.origin.x = self.view.frame.width
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                 moviePanel.frame.origin.x = originalX
            }, completion: nil)
        }
        
        // The original code re-added tap gesture recognizer. If it's on moviePanel, it stays.
        // It also started CSAnimation.
        // The simplified animation above doesn't need a start call.
    }

    // Helper from Obj-C
    private func stringCleanser(_ inString: String) -> String {
        // Replaces hyphens with spaces
        return inString.replacingOccurrences(of: "-", with: " ")
    }
    
    // Game Over logic (if any, not detailed in original properties)
    // func showGameOver() { ... }
    // func hideGameOver() { ... }
    // func beginNextTurn() { ... } // If turns exist
}
