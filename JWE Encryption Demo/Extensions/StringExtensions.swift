import UIKit

// swiftlint:disable force_unwrapping
extension String {
    var data: Data {
        self.data(using: .utf8)!
    }
    
    func encodeBase64URL() -> String {
        let base64Encoded = self.data.base64URLEncodedString()
      
        return base64Encoded
    }
    
    func decodeBase64URL() -> String {
        let base64Decoded = Data(base64URLEncoded: self)!
        let decodedString = String(data: base64Decoded, encoding: .utf8)!
        
        return decodedString
    }
    
    func decodeBase64URLData() -> Data {
        let base64Decoded = Data(base64URLEncoded: self)!
        
        return base64Decoded
    }
}
