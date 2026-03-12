import UIKit

public class SecretKey {
    public let keyData: Data // 32 bytes
    public let macKey: Data  // 16 bytes
    public let encKey: Data  // 16 bytes
    
    private let validKeySize = 32
    
    public convenience init(base64EncodedKey: String) throws {
        try self.init(base64EncodedKey.decodeBase64URLData())
    }
    
    public convenience init(key: String) throws {
        try self.init(key.data)
    }
    
    public init(_ data: Data) throws {
        self.keyData = data
        
        // validate secret key data length
        if self.keyData.count != self.validKeySize {
            throw AESError.wrongKeyLength
        }
        
        let keyComponents = keyData.split() // 0..15 == HMAC key, 16..31 == AES-128 key
        self.macKey = keyComponents.left
        self.encKey = keyComponents.right
    }
}
