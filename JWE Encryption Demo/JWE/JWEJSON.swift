import UIKit
    /*
     JWE JSON Serialization ( https://datatracker.ietf.org/doc/html/draft-ietf-jose-json-web-encryption-31#section-7.2 )
     
     The JWE JSON Serialization represents encrypted content as a JSON
        object.  Content using the JWE JSON Serialization can be encrypted to
        more than one recipient.
     
     Parameter: protected
     The "protected" member MUST be present and contain the value
           BASE64URL(UTF8(JWE Protected Header)) when the JWE Protected
           Header value is non-empty; otherwise, it MUST be absent.  These
           Header Parameter values are integrity protected.

     Parameter: unprotected
     The "unprotected" member MUST be present and contain the value JWE
           Shared Unprotected Header when the JWE Shared Unprotected Header
           value is non-empty; otherwise, it MUST be absent.  This value is
           represented as an unencoded JSON object, rather than as a string.
           These Header Parameter values are not integrity protected.

     Parameter: iv
     The "iv" member MUST be present and contain the value
           BASE64URL(JWE Initialization Vector) when the JWE Initialization
           Vector value is non-empty; otherwise, it MUST be absent.

     Parameter: tag
     The "tag" member MUST be present and contain the value
           BASE64URL(JWE Authentication Tag) when the JWE Authentication Tag
           value is non-empty; otherwise, it MUST be absent.

     Parameter: ciphertext
     The "ciphertext" member MUST be present and contain the value
           BASE64URL(JWE Ciphertext).
     
     Example JSON definition ( https://datatracker.ietf.org/doc/html/draft-ietf-jose-json-web-encryption-31#appendix-A.4.7 )
     {
         "ciphertext":"<ciphertext contents>",
         "iv":"<initialization vector contents>",
         "tag":"<authentication tag contents>",
         "unprotected":<non-integrity-protected shared header contents>,
     }
     
     Unprotected
     
     Parameter: alg ( https://datatracker.ietf.org/doc/html/draft-ietf-jose-json-web-encryption-31#section-4.1.1 )
     The "alg" (algorithm) Header Parameter identifies the cryptographic
        algorithm
     Default value: "dir"
     
     Parameter: enc ( https://datatracker.ietf.org/doc/html/draft-ietf-jose-json-web-encryption-31#section-4.1.2 )
     The "enc" (encryption algorithm) Header Parameter identifies the
        content encryption algorithm used to encrypt the Plaintext to produce
        the Ciphertext.
     Default vlaue: "A128CBC-HS256" ( https://datatracker.ietf.org/doc/html/draft-ietf-jose-json-web-algorithms#section-5.2.3 )
     
     Example:
     unprotected = {
         alg = "dir"
         enc = "A128CBC-HS256"
     }
     
     */

public struct Unprotected: Codable {
    public let alg: String
    public let enc: String
    public init(_ alg: String = "dir",
                _ enc: String = "A128CBC-HS256") {
        self.alg = alg
        self.enc = enc
    }
}

public struct JWEDecodedData {
    public let ciphertext: Data
    public let iv: Data
    public let tag: Data
}

public struct JWEJSON: Codable {
    public let ciphertext: String
    public let iv: String
    public let tag: String
    public let unprotected: Unprotected
    
    
    //        var a_cipheredtext = a_json.ciphertext.decodeBase64URLData()
    //        var a_iv = a_json.iv.decodeBase64URLData()
    //        var a_tag = a_json.tag.decodeBase64URLData()
        
    public init(jsonString: String) throws {
        do {
            self = try Data.decode(fromJSONContent: jsonString)
        } catch {
            throw CustomError.decodingFailed
        }
    }
    
    public func toDecoded() -> JWEDecodedData {
        return JWEDecodedData(ciphertext: ciphertext.decodeBase64URLData(),
                              iv: iv.decodeBase64URLData(),
                              tag: tag.decodeBase64URLData())
    }
    
    public func toDictionary() -> [String: Any] {
        let jweResponse: [String : Any] = [
            "unprotected" : [
                "alg" : "dir",
                "enc" : "A128CBC-HS256"
            ],
            "iv" : iv,
            "ciphertext" : ciphertext,
            "tag" : tag
        ]
        
        return jweResponse
    }
}
