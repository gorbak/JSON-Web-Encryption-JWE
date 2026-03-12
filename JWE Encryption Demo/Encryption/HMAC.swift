import Foundation
import CommonCrypto

enum HMACError: Error {
    case algorithmNotSupported
    case inputMustBeGreaterThanZero
}

struct HMAC {
    typealias KeyType = Data

    /// Calculates a HMAC of an input with a specific HMAC algorithm and the corresponding HMAC key.
    ///
    /// - Parameters:
    ///   - input: The input to calculate a HMAC for.
    ///   - key: The key used in the HMAC algorithm. Must not be empty.
    /// - Returns: The calculated HMAC.
    static func calculate(from input: Data, with key: Data) throws -> Data {
        guard input.count > 0 else {
            throw HMACError.inputMustBeGreaterThanZero
        }
        
        var hmacOutData = Data(count: Int(CC_SHA256_DIGEST_LENGTH)) // the size is 32 seperated into two objects of size 16

        // Force unwrapping is ok, since input count is checked and key and algorithm are assumed not to be empty.
        // From the docs: If the baseAddress of this buffer is nil, the count is zero.
        // swiftlint:disable force_unwrapping
        hmacOutData.withUnsafeMutableBytes { hmacOutBytes in
            key.withUnsafeBytes { keyBytes in
                input.withUnsafeBytes { inputBytes in
                    CCHmac(
                        CCAlgorithm(kCCHmacAlgSHA256),
                        keyBytes.baseAddress!, key.count,
                        inputBytes.baseAddress!, input.count,
                        hmacOutBytes.baseAddress!
                    )
                }
            }
        }
        // swiftlint:enable force_unwrapping

        return hmacOutData
    }
}
