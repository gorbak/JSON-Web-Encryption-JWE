enum EncryptionHelper {
    public static func encrypt(plaintext: String, key: String) throws -> String {
        do {
            let plaintextData = plaintext.data
            let keyData = key.decodeBase64URLData() // NOTE: The key string must be base64 encoded!
            
            let jsonString: String = try JWE.encrypt(plaintext: plaintextData, keyData: keyData).str as String
            
            return jsonString.encodeBase64URL()
        } catch {
            throw error
        }
    }
    
    public static func decrypt(input: String, key: String, isBase64Encoded: Bool) throws -> String {
        var jsonString: String = ""
        
        if isBase64Encoded {
            jsonString = input.decodeBase64URL()
        }

        let json: JWEJSON = try JWEJSON(jsonString: jsonString)
        let decodedKey = key.decodeBase64URLData() // NOTE: The key string must be base64 encoded!
           
        let decryptedData = try JWE.decrypt(json: json, key: decodedKey)
                
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }
}
