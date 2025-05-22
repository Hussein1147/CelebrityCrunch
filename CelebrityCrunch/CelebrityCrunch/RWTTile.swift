import Foundation

@objc(RWTTile) // Explicitly set the Objective-C name if needed, good practice for migration
public class RWTTile: NSObject {
    @objc public var tileColumn: Int = 0
    @objc public var tileRow: Int = 0

    // If there was an init method in Objective-C, like -(instancetype)init;
    // a public override init() {} might be needed depending on usage.
    // For this simple class, the default initializer should suffice for Swift usage,
    // and Objective-C will use its alloc-init pattern.
    // No custom initializers were present in the Obj-C version.

    // No other methods were present in the Obj-C version.
}
