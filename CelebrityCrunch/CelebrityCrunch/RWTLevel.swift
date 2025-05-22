import Foundation

// Assuming RWTActor and RWTTile are already Swift classes
// GameViewDelegate needs to be accessible from Swift.
// If it's an Obj-C protocol, it should be in the bridging header.
// For now, we'll assume it's available or define a placeholder if necessary.

// Placeholder for GameViewDelegate if not bridged yet.
// If GameViewController.h is in bridging header, this isn't needed.
// @objc public protocol GameViewDelegate: NSObjectProtocol {
//     func updateScore() -> Int
// }

@objc(RWTLevel)
public class RWTLevel: NSObject, GameViewDelegate {

    @objc public static let NumColumns = 5
    @objc public static let NumRows = 5

    // Updated types for actorMap and movieMap
    @objc public var actorMap: [String: [String]]? 
    @objc public var movieMap: [String: [String]]?
    
    // Lazy initialization for movie property
    @objc public private(set) lazy var movie: RWTMovie = RWTMovie()

    @objc public private(set) var score: Int = 0

    // Using Swift arrays for the grid. These will be initialized in init.
    // These store optionals because a position might not have an actor or tile.
    public var actors: [[RWTActor?]] = Array(repeating: Array(repeating: nil, count: NumRows), count: NumColumns)
    public var tiles: [[RWTTile?]] = Array(repeating: Array(repeating: nil, count: NumRows), count: NumColumns)

    // Private properties - using Swift native types
    private var currentChosenActors: [RWTActor] = [] 
    private var currentChosenActorSpriteNames: [String] = [] // Names of actors in the current selection attempt
    private var historicallyChosenActorSpriteNames: Set<String> = [] // All unique actor names picked in the level
    
    private var levelMovieTitles: [String] = [] // Assuming movie names are strings
    private var enumerator: NSEnumerator? // Or a Swift iterator if applicable
    
    private var matchScore: Int = 0 // Kept from Obj-C version

    // Constants from Obj-C version
    private let MATCH_BONUS = 4
    private let UNMATCHED_PENALTY = 1

    @objc
    public init(firstFilename actorToMovieFile: String, secondFile movieToActorFile: String, thirdFile levelLayoutFile: String) {
        super.init()

        // Load JSON data with improved type safety
        self.actorMap = loadTypedJSON(filename: actorToMovieFile)
        if self.actorMap == nil {
            print("Error loading actorToMovieFile: \(actorToMovieFile)")
        }

        self.movieMap = loadTypedJSON(filename: movieToActorFile)
        if self.movieMap == nil {
            print("Error loading movieToActorFile: \(movieToActorFile)")
        } else {
            if let allKeys = self.movieMap?.keys {
                 self.levelMovieTitles = Array(allKeys)
            }
            // Set the map for the movie object.
            self.movie.map = self.movieMap 
        }
        
        // Initialize tiles based on levelLayoutFile data
        // Assuming levelLayoutFile contains {"tiles": [[Int]]} structure
        if let levelLayoutData = loadGenericJSON(filename: levelLayoutFile),
           let tilesArray = levelLayoutData["tiles"] as? [[Int]] {
            for (r, rowArray) in tilesArray.enumerated() {
                // In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down if it's not already.
                // The Obj-C code did: NSInteger tileRow = NumRows - row - 1;
                // Assuming r is 'row' from the JSON.
                let tileRowForGrid = RWTLevel.NumRows - 1 - r // Convert JSON row to grid row (0,0 at bottom-left)
                
                for (c, value) in rowArray.enumerated() {
                    if c < RWTLevel.NumColumns && tileRowForGrid >= 0 && tileRowForGrid < RWTLevel.NumRows {
                        if value == 1 {
                            let tile = RWTTile() 
                            tile.tileColumn = c
                            tile.tileRow = r // Store original JSON row index, or tileRowForGrid if preferred
                            self.tiles[c][tileRowForGrid] = tile
                        }
                    }
                }
            }
        } else {
            print("Error loading levelLayoutFile: \(levelLayoutFile) or parsing 'tiles' array.")
        }
        
        // Initialize enumerator for levelMovieTitles (if still using NSEnumerator approach for nextLevel)
        if !self.levelMovieTitles.isEmpty {
            self.enumerator = (self.levelMovieTitles as NSArray).objectEnumerator()
        }
        
        // Ensure movie property is initialized and its map is set (done above)
        // self.movie is already lazy initialized.
        // self.movie.map was set above.
    }

    // Typed JSON loading for [String: [String]]
    private func loadTypedJSON(filename: String) -> [String: [String]]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("Error: Could not find the JSON file: \(filename).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
            return decodedData
        } catch {
            print("Error: Could not load or parse typed JSON from file \(filename).json: \(error)")
            return nil
        }
    }
    
    // Generic JSON loading for other structures like level layout
    private func loadGenericJSON(filename: String) -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("Error: Could not find the JSON file: \(filename).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return jsonResult as? [String: Any]
        } catch {
            print("Error: Could not load or parse generic JSON from file \(filename).json: \(error)")
            return nil
        }
    }

    // --- GameViewDelegate conformance ---
    @objc public func updateScore() -> Int {
        return self.score
    }

    // --- Placeholder for other methods ---
    // These will be implemented in subsequent steps.

    @objc public func shuffle() -> Set<RWTActor> {
        // Port logic from Objective-C
        // Ensure it calls createInitialActors and returns a Swift Set
        _ = self.reShuffleInternalActors() // Clear existing actors first
        return self.createInitialActors()
    }

    // Internal helper for reShuffle to avoid returning from within reShuffle itself
    private func reShuffleInternalActors() -> Set<RWTActor> {
        var removedActors = Set<RWTActor>()
        for c in 0..<RWTLevel.NumColumns {
            for r in 0..<RWTLevel.NumRows {
                if let actor = actors[c][r] {
                    removedActors.insert(actor)
                    actors[c][r] = nil
                }
            }
        }
        return removedActors
    }
    
    @objc public func reShuffle() -> Set<RWTActor> {
        // Port logic from Objective-C
        // This should clear the board and then call shuffle (or createInitialActors)
        let removedActors = self.reShuffleInternalActors()
        // The original Obj-C reShuffle returned the set of actors *before* reshuffling.
        // Then GameViewController called shuffle again.
        // For now, returning the actors that were on the board.
        return removedActors
    }

    @objc public func actor(atColumn column: Int, row: Int) -> RWTActor? {
        guard column >= 0, column < RWTLevel.NumColumns, row >= 0, row < RWTLevel.NumRows else {
            return nil
        }
        return actors[column][row]
    }

    @objc public func tile(atColumn column: Int, row: Int) -> RWTTile? {
        guard column >= 0, column < RWTLevel.NumColumns, row >= 0, row < RWTLevel.NumRows else {
            return nil
        }
        return tiles[column][row]
    }
    
    @objc public func chooseActor(atColumn column: Int, rowInGrid: Int) {
        guard let actor = self.actor(atColumn: column, row: rowInGrid) else {
            print("No actor at column \(column), row \(rowInGrid)")
            return
        }

        currentChosenActors = [actor] // Reset for current selection
        currentChosenActorSpriteNames = []

        if let actorSpriteName = actor.spriteName() {
            // Check against historically chosen names to prevent re-selecting already matched ones
            // or apply game-specific logic for re-selection.
            // The original `chosenActorNames` seemed to accumulate all names picked in a round.
            // Using `historicallyChosenActorSpriteNames` for that now.
            if historicallyChosenActorSpriteNames.contains(actorSpriteName) && actor.matched {
                 print("Actor \(actorSpriteName) was already part of a successful match.")
                // Depending on game rules, may or may not want to return here.
                // For now, let's allow re-selection for potential different matches if not yet matched in *this* turn.
                // Or, if an actor can only be matched once ever:
                // return 
            }
            
            currentChosenActorSpriteNames.append(actorSpriteName)
            // Add to history only after a successful match, or here if all attempts should be recorded.
            // For now, adding here to match original pattern of chosenActorNames accumulation.
            historicallyChosenActorSpriteNames.insert(actorSpriteName)
            
        } else {
            print("Warning: Chosen actor is missing a sprite name.")
            // Potentially return or handle error
            return
        }

        matchScore = 0 // Reset matchScore for this specific choice/attempt
        
        // Perform match checking.
        // This logic implies only the *current* selection (currentChosenActorSpriteNames) is checked against the movie.
        let matchCount = movie.match(actors: currentChosenActorSpriteNames, withMovie: movie.movieName)
        if matchCount > 0 {
            score += matchCount * MATCH_BONUS 
            // Mark all actors in the current successful selection as matched
            for selectedActor in currentChosenActors {
                selectedActor.matched = true
            }
        } else {
            score -= UNMATCHED_PENALTY
        }
        self.matchScore = matchCount // Store the count of matches for this attempt
        
        print("Score: \(score), Current Chosen Sprites: \(currentChosenActorSpriteNames.count), Match Result: \(matchCount)")
        print("Actor at \(actor.column), \(actor.row), Index: \(actor.actorIndex), Sprite: \(actor.spriteName() ?? "N/A")")
    }

    @objc(removeMatches)
    public func removeMatches() -> Set<RWTActor> {
        let matchedActors = detectMatches()
        for actor in matchedActors {
            if actor.column < RWTLevel.NumColumns && actor.row < RWTLevel.NumRows && actor.column >= 0 && actor.row >= 0 {
                 actors[actor.column][actor.row] = nil
            }
        }
        return matchedActors
    }

    @objc public func fillHoles() -> Set<RWTActor> { // Changed return type
        var newActorsSet = Set<RWTActor>()
        for c in 0..<RWTLevel.NumColumns {
            for r_grid in 0..<RWTLevel.NumRows { // r_grid is the visual row (0 at bottom)
                if tiles[c][r_grid] != nil && actors[c][r_grid] == nil {
                    // Ensure NumActors is greater than 0 to prevent crash with arc4random_uniform
                    guard RWTActor.NumActors > 0 else {
                        print("Error: RWTActor.NumActors is 0, cannot generate random actor index.")
                        continue // Skip filling this hole or handle error appropriately
                    }
                    let newActorIndex = Int(arc4random_uniform(UInt32(RWTActor.NumActors))) + 1
                    let newActor = createActors(atColumn: c, row: r_grid, withIndex: newActorIndex)
                    // The createActors method already places the actor in self.actors
                    newActorsSet.insert(newActor)
                }
            }
        }
        return newActorsSet
    }

    @objc public func nextLevel() -> String? {
        guard !levelMovieTitles.isEmpty else { return nil }
        let randomIndex = Int(arc4random_uniform(UInt32(levelMovieTitles.count)))
        return levelMovieTitles[randomIndex]
    }
    
    // Internal logic methods
    
    private func detectMatches() -> Set<RWTActor> {
        var set = Set<RWTActor>()
        for c in 0..<RWTLevel.NumColumns {
            for r in 0..<RWTLevel.NumRows {
                if let actor = actors[c][r], actor.matched { // Corrected typo
                    set.insert(actor)
                }
            }
        }
        return set
    }

    @objc public func createInitialActors() -> Set<RWTActor> {
        var set = Set<RWTActor>()
        
        if let movieActor = createCurrentMovieActors() {
            set.insert(movieActor)
        }

        var availableIndices = Array(1...RWTActor.NumActors) // 1-based indices
        availableIndices.shuffle() // Shuffle to get random actor types

        for r_grid in 0..<RWTLevel.NumRows { // Iterate grid rows
            for c_grid in 0..<RWTLevel.NumColumns { // Iterate grid columns
                if tiles[c_grid][r_grid] != nil && actors[c_grid][r_grid] == nil { // If tile exists and no actor yet
                    if availableIndices.isEmpty {
                        print("Warning: Ran out of unique actor types for initial setup.")
                        // Fallback: reuse indices or use a fixed random one
                        let actorIndex = Int(arc4random_uniform(UInt32(RWTActor.NumActors))) + 1
                        let actor = createActors(atColumn: c_grid, row: r_grid, withIndex: actorIndex)
                        set.insert(actor)
                        continue
                    }
                    let actorIndex = availableIndices.removeFirst()
                    let actor = createActors(atColumn: c_grid, row: r_grid, withIndex: actorIndex)
                    set.insert(actor)
                }
            }
        }
        return set
    }

    private func createCurrentMovieActors() -> RWTActor? {
        guard let currentMovieName = movie.movieName as String?, !currentMovieName.isEmpty,
              let movieActorNames = movie.getActorList(forMovie: currentMovieName), !movieActorNames.isEmpty else {
            print("No actors found for current movie: \(movie.movieName)")
            return nil
        }

        let randomIndexInMovie = Int(arc4random_uniform(UInt32(movieActorNames.count)))
        let selectedActorName = movieActorNames[randomIndexInMovie]
        
        let actorIdFromName = RWTActor.actorIndex(forName: selectedActorName)

        guard actorIdFromName != NSNotFound else {
            print("Error: Actor name \(selectedActorName) from movie list not found in actor definitions.")
            return nil
        }
        
        // Find an empty tile spot
        // This part needs to be robust: find a random empty tile.
        var availableTileCoords: [(Int, Int)] = []
        for c in 0..<RWTLevel.NumColumns {
            for r_grid in 0..<RWTLevel.NumRows { // r_grid is the visual row, 0 at bottom
                if tiles[c][r_grid] != nil && actors[c][r_grid] == nil {
                    availableTileCoords.append((c, r_grid))
                }
            }
        }
        
        guard !availableTileCoords.isEmpty else {
            print("No empty tiles available to place the current movie actor.")
            return nil
        }
        
        availableTileCoords.shuffle()
        let (col, row_grid) = availableTileCoords.first!
        
        let newActor = createActors(atColumn: col, row: row_grid, withIndex: actorIdFromName)
        print("Placed movie actor \(selectedActorName) (ID: \(actorIdFromName)) at column: \(col), row: \(row_grid) for movie: \(currentMovieName)")
        return newActor
    }

    private func createActors(atColumn column: Int, row: Int, withIndex index: Int) -> RWTActor {
        let actor = RWTActor() // Assumes RWTActor is a Swift class
        actor.actorIndex = index // 1-based
        actor.column = column
        actor.row = row // This is the grid row (visual row)
        
        // Ensure actor is placed in the grid if not already
        if column >= 0 && column < RWTLevel.NumColumns && row >= 0 && row < RWTLevel.NumRows {
            actors[column][row] = actor
        } else {
            print("Error: Attempted to create actor at out-of-bounds location (\(column),\(row)). Actor not placed in grid array.")
        }
        return actor
    }

    // Consider porting getTiles and getActors if they are used by logic not yet ported,
    // or if their specific NSSet behavior is needed. Otherwise, direct array iteration is more Swifty.
}

// Extension for Array shuffle, if not available globally
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
}
