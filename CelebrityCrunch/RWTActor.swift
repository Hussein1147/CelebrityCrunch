import Foundation
import SpriteKit // For SKSpriteNode

// Standard definition for NSNotFound, used for Objective-C compatibility
public let NSNotFound: Int = -1 

// Struct for Codable JSON parsing
struct ActorDefinition: Codable {
    let id: Int // 1-based index
    let name: String
    let spriteBase: String
    let highlightedSuffix: String
    let blueSuffix: String
}

@objc(RWTActor)
public class RWTActor: NSObject {

    @objc public var actorName: String = "" // May be redundant if actorIndex is primary ID
    @objc public var column: Int = 0
    @objc public var row: Int = 0
    @objc public var actorIndex: Int = 0 // 1-based index from JSON
    @objc public var sprite: SKSpriteNode?
    @objc public var matched: Bool = false // Corrected typo from 'machted'

    public override init() {
        super.init()
    }
    
    // --- Static Data & JSON Loading with Codable ---

    // Private static properties for lazy loading JSON data using Codable
    private static let _actorDefinitionsStorage: [ActorDefinition]? = {
        guard let path = Bundle.main.path(forResource: "Actors", ofType: "json") else {
            print("Error: Could not find Actors.json")
            return [] // Return empty on error
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let definitions = try JSONDecoder().decode([ActorDefinition].self, from: data)
            // Warning if NumActors (dynamic) doesn't match a fixed expectation if one existed.
            // print("Loaded \(definitions.count) actor definitions.")
            return definitions
        } catch {
            print("Error: Could not load or parse Actors.json: \(error)")
        }
        return [] // Return empty on error
    }()

    private static let _actorDefinitionsByNameStorage: [String: ActorDefinition]? = {
        guard let definitions = _actorDefinitionsStorage else { return [:] }
        var byName: [String: ActorDefinition] = [:]
        for actorDef in definitions {
            byName[actorDef.name] = actorDef
        }
        return byName
    }()

    // Publicly accessible static computed property for NumActors
    @objc public static var NumActors: Int {
        return _actorDefinitionsStorage?.count ?? 0
    }

    // Publicly accessible static computed properties for actor definitions
    // These are not directly @objc as they return Swift-specific types.
    // Use @objc static func versions for Obj-C access if needed for the collections themselves.
    public static var actorDefinitions: [ActorDefinition]? {
        return _actorDefinitionsStorage
    }

    public static var actorDefinitionsByName: [String: ActorDefinition]? {
        return _actorDefinitionsByNameStorage
    }
    
    // @objc method to get actor data, returning NSDictionary for Obj-C compatibility
    // Changed to return ActorDefinition? for Swift, Obj-C will need bridging if directly accessing
    @objc public static func actorData(forIndex index: Int) -> ActorDefinition? { // index is 1-based
        guard let definitions = self.actorDefinitions, index > 0, index <= definitions.count else {
            // print("Error: actorData(forIndex:) index \(index) out of bounds (1-\(self.NumActors)).")
            return nil
        }
        return definitions[index - 1] // Convert 1-based to 0-based
    }

    @objc public static func actorIndex(forName name: String) -> Int { // returns 1-based index or NSNotFound
        guard let definitionsByName = self.actorDefinitionsByName, let actorDef = definitionsByName[name] else {
            return NSNotFound 
        }
        return actorDef.id
    }

    // --- Instance Methods ---

    @objc public func spriteName() -> String? {
        guard let def = RWTActor.actorData(forIndex: self.actorIndex) else { return nil }
        return def.spriteBase
    }

    @objc public func highlightedSpriteName() -> String? {
        guard let def = RWTActor.actorData(forIndex: self.actorIndex) else { return nil }
        return "\(def.spriteBase)\(def.highlightedSuffix)"
    }

    @objc public func blueHighlightedSpriteName() -> String? {
        guard let def = RWTActor.actorData(forIndex: self.actorIndex) else { return nil }
        return "\(def.spriteBase)\(def.blueSuffix)"
    }
}
