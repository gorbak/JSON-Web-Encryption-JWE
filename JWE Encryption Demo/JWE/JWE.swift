import UIKit
import CommonCrypto

/* JWE Encryption with results Json Serialization representation
   The CommonCrypto algorithms are used for AES and HMAC
 */
enum JWE {
    public static func encrypt(plaintext: Data,
                        keyData: Data) throws -> (jwe: JWEJSON, str: String) {
        let secretKey = try SecretKey(keyData)
        var iv = [UInt8](repeating: 0, count: 16)
        var ret: Int32
        
        // generate random IV
        ret = SecRandomCopyBytes(kSecRandomDefault, iv.count, &iv)
        if ret != 0 {
            throw AESError.ivGenerationFailed
        }
        let ivData = Data(bytes: iv, count: iv.count)
        
        // encrypt the plaintext (AES-128 CBC mode)
        let encrypted = AES.encrypt(data: plaintext,
                                    key: secretKey.encKey,
                                    initializationVector: ivData)

        guard
            let ciphertext = encrypted.data,
            encrypted.status == UInt32(kCCSuccess)
        else {
            throw AESError.encryptingFailed(description: "Encryption error! status: \(encrypted.status).")
        }
        
        // compute AL (there is no AAD, so AL is a 64-bit string of zeros - normally it would be the number of BITS of AAD expressed as big-endian)
        let size = 8
        let al = [UInt8](repeating: 0, count: size)
        let alData = Data(bytes: al, count: size)

        // compute HMAC-SHA256 over IV + ciphertext + AL
        var hmacData = Data(capacity: ivData.count + ciphertext.count + alData.count)
        hmacData.append(ivData)
        hmacData.append(Data(ciphertext))
        hmacData.append(alData)
        
        // Calculate the HMAC for the concatenated input data and compare it with the reference authentication tag.
        let mac = try HMAC.calculate(from: hmacData, with: secretKey.macKey)

        // truncate the mac (first 16 bytes only) to become the tag
        let tagData = [UInt8](mac).splitComponentsAsData().left

        // format the JWE dictionary and return
        let jweResponse: [String : Any] = [
            "unprotected" : [
                "alg" : "dir",
                "enc" : "A128CBC-HS256"
            ],
            "iv" : ivData.base64URLEncodedString(),
            "ciphertext" : Data(ciphertext).base64URLEncodedString(),
            "tag" : tagData.base64URLEncodedString()
        ]

        do {
            let jwePretty: String = String(data: try! JSONSerialization.data(withJSONObject: jweResponse, options: .prettyPrinted), encoding: .utf8)!
            print("NEW JWE:")
            print(jwePretty)
            
            let response = try JWEJSON(jsonString: jwePretty)
            return (response, jwePretty)
        } catch {
            throw AESError.jsonSerializationFailed
        }
    }
    
    /*
     Decrypt the ciphertext encrypted with AES + HMAC, for the given iv, tag and secretKey
     */
    public static func decrypt(_ ciphertext: Data,
                        initializationVector: Data,
                        authenticationTag: Data,
                        keyData: Data) throws -> Data {
        let secretKey = try SecretKey(keyData)

        // Put together the input data for the HMAC. It consists of A || IV || E || AL.
        // compute AL (there is no AAD, so AL is a 64-bit string of zeros - normally it would be the number of BITS of AAD expressed as big-endian)
        let size = 8
        let al = [UInt8](repeating: 0, count: size)
        let alData = Data(bytes: al, count: size)

        // compute HMAC-SHA256 over IV + ciphertext + AL
        var hmacData = Data(capacity: initializationVector.count + ciphertext.count + alData.count)
        hmacData.append(initializationVector)
        hmacData.append(Data(ciphertext))
        hmacData.append(alData)
        
        // Calculate the HMAC for the concatenated input data and compare it with the reference authentication tag.
        let mac = try HMAC.calculate(from: hmacData, with: secretKey.macKey)

        // truncate the mac (first 16 bytes only) to become the tag
        let tagData = [UInt8](mac).splitComponentsAsData().left
        
        guard
            authenticationTag.timingSafeCompare(with: tagData)
        else {
            throw CustomError.genericError
        }

        let decrypted = AES.decrypt(data: ciphertext,
                                    key: secretKey.encKey,
                                    initializationVector: initializationVector)

        guard let decryptedData = decrypted.data else {
            throw CustomError.genericError
        }

        return decryptedData
    }
    
    public static func decrypt(json: JWEJSON, key: Data) throws -> Data {
        let decodedData = json.toDecoded()
        
        return try decrypt(decodedData.ciphertext,
                           initializationVector: decodedData.iv,
                           authenticationTag: decodedData.tag,
                           keyData: key)
    }
}
