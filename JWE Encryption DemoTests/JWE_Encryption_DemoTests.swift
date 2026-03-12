//
//  Created by Tomasz Gorbaczewski on 12/03/2026.
//

import Testing
@testable import JWE_Encryption_Demo
internal import Foundation

struct JWE_Encryption_DemoTests {
    @Test func encryptionDecryptionTest() {
        let input = "{\"exampleJson\":\"value\"}"
        guard let plaintext = input.data(using: .utf8) else {
            Issue.record("Plaintext cannot be nil!")
            return
        }
        let key = "cwrfCIOtWfIOfperoOa1cHQiwFudW5KVg3-3qI1KdTo".decodeBase64URLData()
        
        //--== Encrypt ==--")
        let json: JWEJSON = try! JWE.encrypt(plaintext: plaintext, keyData: key).jwe as JWEJSON

        print("--== Decrypt ==--")
        let decryptedData = try? JWE.decrypt(json: json, key: key)
        
        if let decryptedData {
            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                Issue.record("Decrypted data should be a valid UTF-8")
                return
            }
            
            #expect(decryptedString == input, "Decrypted text should match the input")
        } else {
            Issue.record("Decryption failed!")
        }
    }
}
