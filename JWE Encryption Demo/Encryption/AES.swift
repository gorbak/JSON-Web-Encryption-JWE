import Foundation
import CommonCrypto

enum AESError: Error {
    case wrongKeyLength
    case ivGenerationFailed
    case jsonSerializationFailed
    case encryptingFailed(description: String)
}

enum AES {
    typealias KeyType = Data
}

extension AES {
    public static func encrypt(data: Data,
                               key: Data,
                               initializationVector: Data) -> (data: Data?, status: Int32) {
        return CBCCrypt(operation: CCOperation(kCCEncrypt),
                        data: data,
                        key: key,
                        algorithm: CCAlgorithm(kCCAlgorithmAES128),
                        initializationVector: initializationVector,
                        padding: CCOptions(kCCOptionPKCS7Padding))
    }
        
    public static func decrypt(data: Data,
                               key: Data,
                               initializationVector: Data) -> (data: Data?, status: Int32) {
        return CBCCrypt(operation: CCOperation(kCCDecrypt),
                        data: data,
                        key: key,
                        algorithm: CCAlgorithm(kCCAlgorithmAES128),
                        initializationVector: initializationVector,
                        padding: CCOptions(kCCOptionPKCS7Padding))
    }
    
    // swiftlint:disable:next function_parameter_count
    private static func CBCCrypt(
        operation: CCOperation,
        data: Data,
        key: Data,
        algorithm: CCAlgorithm,
        initializationVector: Data,
        padding: CCOptions
    ) -> (data: Data?, status: Int32) {
        let dataLength = data.count
        let keyLength = key.count
        let ivLength = initializationVector.count

        guard dataLength > 0, keyLength > 0, ivLength > 0 else {
            return (nil, CCCryptorStatus(kCCParamError))
        }

        // AES's 128 block size is fixed for every key length and guaranteed not to be 0.
        let cryptLength  = size_t(dataLength + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)

        var numBytesCrypted: size_t = 0

        // Force unwrapping is ok, since buffers are guaranteed not to be empty.
        // From the docs: If the baseAddress of this buffer is nil, the count is zero.
        // swiftlint:disable force_unwrapping
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                initializationVector.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes -> Int32 in
                        CCCrypt(operation,
                                algorithm,
                                padding,
                                keyBytes.baseAddress!, keyLength,
                                ivBytes.baseAddress!,
                                dataBytes.baseAddress!, dataLength,
                                cryptBytes.baseAddress!, cryptLength,
                                &numBytesCrypted)
                    }
                }
            }
        }
        // swiftlint:enable force_unwrapping

        guard cryptStatus == kCCSuccess else {
            return (nil, cryptStatus)
        }

        cryptData.removeSubrange(numBytesCrypted..<cryptLength)

        return (cryptData, cryptStatus)
    }
}
