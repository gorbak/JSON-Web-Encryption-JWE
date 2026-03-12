import UIKit

extension Data {
    public init?(base64URLEncoded base64URLString: String) {
        var s = base64URLString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let mod = s.count % 4
        switch mod {
        case 0: break
        case 2: s.append("==")
        case 3: s.append("=")
        default: return nil
        }

        self.init(base64Encoded: s)
    }
    
    public var array: [UInt8] {
        [UInt8](self)
    }
    
    public var bytes: Array<UInt8> {
        Array(self)
    }
    
    func split() -> (left: Data, right: Data) {
        let array = self.array
        let ct = array.count
        let half = ct / 2
        let leftSplit = array[0 ..< half]
        let rightSplit = array[half ..< ct]
        return (left: leftSplit.data, right: rightSplit.data)
    }
    
    public func base64URLEncodedString() -> String {
        let s = self.base64EncodedString()
        return s
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
    
    static func decode<T: Decodable>(fromJSONContent json: String) throws -> T {
        do {
            guard let data = json.data(using: .utf8) else { throw CustomError.parsingError }
            let object: T = try data.decoded()
            return object
        } catch {
            throw CustomError.parsingError
        }
    }
    
    private func decoded<T: Decodable>() throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
    
    /// Compares data in constant-time.
    ///
    /// The running time of this method is independent of the data compared, making it safe to use for comparing secret values such as cryptographic MACs.
    ///
    /// The number of bytes of both data are expected to be of same length.
    ///
    /// - Parameter other: Other data for comparison.
    /// - Returns: `true` if both data are equal, otherwise `false`.
    public func timingSafeCompare(with other: Data) -> Bool {
        assert(self.count == other.count, "parameters should be of same length")
        if #available(iOS 10.1, *) {
            return timingsafe_bcmp([UInt8](self), [UInt8](other), self.count) == 0
        } else {
            return _timingSafeCompare(with: other)
        }
    }

    public func _timingSafeCompare(with other: Data) -> Bool {
        assert(self.count == other.count, "parameters should be of same length")
        var diff: UInt8 = 0
        for i in 0 ..< self.count {
            diff |= self[i] ^ other[i]
        }
        return diff == 0
    }
}
