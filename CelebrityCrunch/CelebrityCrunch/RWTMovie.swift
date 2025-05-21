import Foundation

@objc(RWTMovie)
public class RWTMovie: NSObject {

    @objc public var movieName: String = ""
    @objc public var actorList: [String]? // List of actor names for the current movieName
    @objc public var map: [String: [String]]? // Loaded from movieToActor.json

    public override init() {
        super.init()
    }

    @objc public func getActorList(forMovie movieNameInput: String) -> [String]? {
        // Use the map property to find the list of actors for the given movieNameInput.
        // This fixes the bug in the original Obj-C version.
        return self.map?[movieNameInput]
    }

    @objc public func match(actors selectedActors: [String], withMovie movieNameToMatch: String) -> Int {
        guard let officialActorList = self.getActorList(forMovie: movieNameToMatch) else {
            // If the movie isn't in the map or has no actors, there can be no match.
            return 0
        }
        
        // Find the intersection of selectedActors and the official list.
        let selectedSet = Set(selectedActors)
        let officialSet = Set(officialActorList)
        
        let commonActors = selectedSet.intersection(officialSet)
        
        // Return the count of common actors.
        return commonActors.count
    }
}
