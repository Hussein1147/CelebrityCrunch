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

    @objc public var actorMap: [String: Any]?
    @objc public var movieMap: [String: Any]? // Or more specific like [String: [String]]
    
    // Lazy initialization for movie property
    @objc public private(set) lazy var movie: RWTMovie = RWTMovie()

    @objc public private(set) var score: Int = 0

    // Using Swift arrays for the grid. These will be initialized in init.
    // These store optionals because a position might not have an actor or tile.
    public var actors: [[RWTActor?]] = Array(repeating: Array(repeating: nil, count: NumRows), count: NumColumns)
    public var tiles: [[RWTTile?]] = Array(repeating: Array(repeating: nil, count: NumRows), count: NumColumns)

    // Private properties
    private var currentChosenActor: [RWTActor] = [] // Changed from NSMutableArray
    private var currentChosenActorNames: [String] = [] // Changed from NSMutableArray
    private var chosenActorNames: [String] = [] // Changed from NSMutableArray
    
    private var levelMovies: [String] = [] // Assuming movie names are strings
    private var enumerator: NSEnumerator? // Or a Swift iterator if applicable
    
    private var matchScore: Int = 0 // Kept from Obj-C version

    // Constants from Obj-C version
    private let MATCH_BONUS = 4
    private let UNMATCHED_PENALTY = 1

    @objc
    public init(firstFilename actorFile: String, secondFile movieFile: String, thirdFile levelFile: String) {
        super.init()

        // Load JSON data
        if let mapData = loadJSON(filename: actorFile) {
            self.actorMap = mapData
        } else {
            print("Error loading actorFile: \(actorFile)")
            // Handle error, perhaps by not fully initializing or setting a failure state
        }

        if let mapData = loadJSON(filename: movieFile) {
            self.movieMap = mapData
            if let allKeys = self.movieMap?.keys {
                 self.levelMovies = Array(allKeys)
                 // Initialize enumerator if needed
                 // self.enumerator = (self.levelMovies as NSArray).objectEnumerator() // Example if NSEnumerator is kept
            }
            // Set the map for the movie object. This was done in GameViewController before.
            self.movie.map = self.movieMap as? [String: [String]]

        } else {
            print("Error loading movieFile: \(movieFile)")
        }
        
        // Initialize tiles based on levelFile data
        if let levelData = loadJSON(filename: levelFile),
           let tilesArray = levelData["tiles"] as? [[Int]] {
            for (r, rowArray) in tilesArray.enumerated() {
                // In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down if it's not already.
                // The Obj-C code did: NSInteger tileRow = NumRows - row - 1;
                // Assuming r is 'row' from the JSON.
                let tileRowForGrid = RWTLevel.NumRows - 1 - r // Convert JSON row to grid row
                
                for (c, value) in rowArray.enumerated() {
                    if c < RWTLevel.NumColumns && tileRowForGrid >= 0 && tileRowForGrid < RWTLevel.NumRows {
                        if value == 1 {
                            let tile = RWTTile() // Assuming RWTTile is a Swift class now
                            tile.tileColumn = c
                            tile.tileRow = r // Store original JSON row, or adjust as needed
                            self.tiles[c][tileRowForGrid] = tile
                        }
                    }
                }
            }
        } else {
            print("Error loading levelFile: \(levelFile) or parsing 'tiles' array.")
        }
        
        // Initialize enumerator for levelMovies (if still using NSEnumerator)
        if !self.levelMovies.isEmpty {
            self.enumerator = (self.levelMovies as NSArray).objectEnumerator()
        }
        
        // Ensure movie property is initialized and its map is set
        // self.movie is already lazy initialized.
        // self.movie.map was set above.
    }

    // Helper function to load JSON from a file (simplified)
    private func loadJSON(filename: String) -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("Could not find the level file: \(filename).json")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return jsonResult as? [String: Any]
        } catch {
            print("Could not load or parse JSON from file \(filename).json: \(error)")
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

        currentChosenActor = [] // Reset for current selection
        currentChosenActorNames = []

        currentChosenActor.append(actor)
        
        // Assuming actor.spriteName() is available and returns String?
        if let actorSpriteName = actor.spriteName() {
            if chosenActorNames.contains(actorSpriteName) {
                // Actor already chosen, do nothing or handle as per game logic
                return
            } else {
                currentChosenActorNames.append(actorSpriteName)
                chosenActorNames.append(actorSpriteName)
            }
        } else {
            // Handle missing sprite name if necessary
            print("Warning: Chosen actor is missing a sprite name.")
            return // Or proceed without name-based checks if appropriate
        }

        matchScore = 0 // Reset matchScore for this choice
        
        // Perform match checking
        // The original Obj-C code iterated through `currentChosenActor` (which would be just one actor here)
        // This loop seems redundant if currentChosenActor always has one actor.
        // Sticking to original logic pattern for now.
        for chosenActorInstance in currentChosenActor { // This loop will run once.
            let matchCount = movie.match(actors: currentChosenActorNames, withMovie: movie.movieName)
            if matchCount > 0 { // Assuming match returns count of matched items.
                score += matchCount * MATCH_BONUS // Or just MATCH_BONUS if matchCount is bool-like
                chosenActorInstance.machted = true // Typo 'machted' from original
            } else {
                score -= UNMATCHED_PENALTY
            }
            self.matchScore = matchCount // Store the count of matches
        }
        
        print("Score: \(score), Chosen Actors: \(currentChosenActorNames.count), Match Score: \(matchScore)")
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

    @objc public func fillHoles() -> RWTActor? {
        var lastFilledActor: RWTActor? = nil
        for c in 0..<RWTLevel.NumColumns {
            for r in 0..<RWTLevel.NumRows {
                if tiles[c][r] != nil && actors[c][r] == nil {
                    let newActorIndex = Int(arc4random_uniform(UInt32(RWTActor.NumActors))) + 1
                    let newActor = createActors(atColumn: c, row: r, withIndex: newActorIndex)
                    actors[c][r] = newActor
                    lastFilledActor = newActor
                }
            }
        }
        return lastFilledActor // Returns only the last actor created
    }

    @objc public func nextLevel() -> String? {
        guard !levelMovies.isEmpty else { return nil }
        let randomIndex = Int(arc4random_uniform(UInt32(levelMovies.count)))
        return levelMovies[randomIndex]
    }
    
    // Internal logic methods
    
    private func detectMatches() -> Set<RWTActor> {
        var set = Set<RWTActor>()
        for c in 0..<RWTLevel.NumColumns {
            for r in 0..<RWTLevel.NumRows {
                if let actor = actors[c][r], actor.machted { // Typo 'machted'
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
