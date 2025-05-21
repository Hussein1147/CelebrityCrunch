import Foundation

@objc class TestSwiftClass : NSObject { // Ensure it's NSObject subclass and @objc for Obj-C visibility
    @objc func hello() {
        print("Hello from Swift!")
    }

    @objc func testObjC() {
        // Assuming AppDelegate is imported via the bridging header
        let appDelegate = AppDelegate()
        print("Can access AppDelegate from Swift: \(appDelegate)")
        
        // Example of using another class from the bridging header
        let actor = RWTActor()
        actor.actorIndex = 1 // Set a 1-based index
        if let spriteName = actor.spriteName() {
            print("Actor with index 1 has sprite: \(spriteName)")
        } else {
            print("Could not get spriteName for actor with index 1.")
        }
    }
}
