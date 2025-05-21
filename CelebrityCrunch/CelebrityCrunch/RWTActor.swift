import Foundation
import SpriteKit // For SKSpriteNode

// Using NSNotFound for consistency if this value is used in Obj-C parts that expect it.
// Otherwise, returning an optional Int? (nil for not found) would be more Swifty.
// public let NSNotFound: Int = -1 // Standard definition

@objc(RWTActor)
public class RWTActor: NSObject {

    @objc public var actorName: String = "" // May not be strictly needed if actorIndex is the primary ID
    @objc public var column: Int = 0
    @objc public var row: Int = 0
    @objc public var actorIndex: Int = 0 // 1-based index from JSON
    @objc public var sprite: SKSpriteNode?
    @objc public var machted: Bool = false // Typo for 'matched'

    // Default initializer
    public override init() {
        super.init()
        // Call loadActorDefinitions to ensure data is ready when an instance is created,
        // especially if actorName might be set based on actorIndex soon after.
        // However, instance methods like spriteName() will call it lazily if not.
        // RWTActor.loadActorDefinitions() // Not strictly necessary here due to lazy loading in accessors
    }
    
    // --- Static Data & JSON Loading ---

    public static let NumActors = 70 // Or derive from _actorDefinitions.count after loading

    // Private static properties for lazy loading JSON data
    private static let _actorDefinitionsStorage: [[String: Any]]? = {
        guard let path = Bundle.main.path(forResource: "Actors", ofType: "json") else {
            print("Could not find Actors.json")
            return []
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonArray = jsonResult as? [[String: Any]] {
                if jsonArray.count != NumActors {
                    print("Warning: NumActors constant (\(NumActors)) does not match loaded actor definitions count (\(jsonArray.count)).")
                }
                return jsonArray
            }
        } catch {
            print("Could not load or parse Actors.json: \(error)")
        }
        return [] // Return empty on error to prevent repeated load attempts
    }()

    private static let _actorDefinitionsByNameStorage: [String: [String: Any]]? = {
        guard let definitions = _actorDefinitionsStorage else { return [:] }
        var byName: [String: [String: Any]] = [:]
        for actorDict in definitions {
            if let name = actorDict["name"] as? String {
                byName[name] = actorDict
            }
        }
        return byName
    }()

    // Publicly accessible static computed properties that use the lazy storage
    public static var actorDefinitions: [[String: Any]]? {
        return _actorDefinitionsStorage
    }

    public static var actorDefinitionsByName: [String: [String: Any]]? {
        return _actorDefinitionsByNameStorage
    }
    
    // No explicit loadActorDefinitions() needed due to lazy static properties.
    // Accessing actorDefinitions or actorDefinitionsByName will trigger the load.

    @objc public static func actorData(forIndex index: Int) -> [String: Any]? { // index is 1-based
        guard let definitions = self.actorDefinitions, index > 0, index <= definitions.count else {
            print("Error: actorData(forIndex:) index \(index) out of bounds (1-\(self.actorDefinitions?.count ?? 0)).")
            return nil
        }
        return definitions[index - 1] // Convert 1-based to 0-based
    }

    @objc public static func actorIndex(forName name: String) -> Int { // returns 1-based index or NSNotFound
        guard let definitionsByName = self.actorDefinitionsByName, let actorDict = definitionsByName[name], let id = actorDict["id"] as? Int else {
            return NSNotFound 
        }
        return id
    }

    // --- Instance Methods ---

    @objc public func spriteName() -> String? {
        guard let data = RWTActor.actorData(forIndex: self.actorIndex) else { return nil }
        return data["spriteBase"] as? String
    }

    @objc public func highlightedSpriteName() -> String? {
        guard let data = RWTActor.actorData(forIndex: self.actorIndex),
              let base = data["spriteBase"] as? String,
              let suffix = data["highlightedSuffix"] as? String else { return nil }
        return "\(base)\(suffix)"
    }

    // Corrected typo from blueHilightedSpriteNames
    @objc public func blueHighlightedSpriteName() -> String? {
        guard let data = RWTActor.actorData(forIndex: self.actorIndex),
              let base = data["spriteBase"] as? String,
              let suffix = data["blueSuffix"] as? String else { return nil }
        return "\(base)\(suffix)"
    }
    
    // The Objective-C instance method -(NSUInteger)actorIndex:(NSString *)actorName is omitted.
    // RWTLevel.m was already updated to use `[RWTActor actorIndexForName:]` which will now
    // map to the static Swift func `RWTActor.actorIndex(forName:)`.
    // The conversion from 1-based ID (from JSON) to 0-based index, if needed by specific
    // Obj-C clients, should be handled by those clients or via a specific Swift helper if required.
    // RWTLevel.m's createCurrentMovieActors was:
    // NSInteger actorIdFromName = [RWTActor actorIndexForName:selectedActorName]; // This is 1-based or NSNotFound
    // if (actorIdFromName != NSNotFound) { index = actorIdFromName; /* this index is 1-based */ }
    // This pattern is compatible with the new Swift static method.
}

// Helper for DispatchQueue.once behavior if needed, though lazy static vars are preferred.
// public extension DispatchQueue {
//    private static var _onceTracker = [String]()
//    static func once(token: String, block: () -> Void) {
//        objc_sync_enter(self)
//        defer { objc_sync_exit(self) }
//        if _onceTracker.contains(token) { return }
//        _onceTracker.append(token)
//        block()
//    }
// }
// Example usage: DispatchQueue.once(token: "com.example.loadActorDefinitions", block: { ... })
// But for this case, lazy static properties achieve the goal more simply.
