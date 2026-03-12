//
//  ViewController.swift
//
//  Created by Tomasz Gorbaczewski on 24/11/2022.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var view_message: UIView!
    @IBOutlet weak var l_InfoMessage: UILabel!
    
    // Encryption
    @IBOutlet weak var tv_enc_PlainText: UITextView!
    @IBOutlet weak var tv_enc_SecretKey: UITextView!
    @IBOutlet weak var btn_enc_Encrypt: UIButton!
    @IBOutlet weak var tv_enc_Result: UITextView!

    // Decryption
    @IBOutlet weak var tv_dec_EncryptedJSON: UITextView!
    @IBOutlet weak var sw_dec_DecodeBase64: UISwitch!
    @IBOutlet weak var tv_dec_SecretKey: UITextView!
    @IBOutlet weak var btn_dec_Decrypt: UIButton!
    @IBOutlet weak var tv_dec_Result: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        testEncryption()
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers() {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func returnPressed(_ sender: Any) {
        dismissKeyboard()
    }
    
    func testEncryption() {
        let plaintext = "{\"exampleJson\":\"value\"}".data(using: .utf8)!
        let key = "cwrfCIOtWfIOfperoOa1cHQiwFudW5KVg3-3qI1KdTo".decodeBase64URLData()
        
        print("--== Encrypt ==--")
        let json: JWEJSON = try! JWE.encrypt(plaintext: plaintext, keyData: key).jwe as JWEJSON
        let decodedData = json.toDecoded()

        print("--== Decrypt ==--")
        let decryptedData = try? JWE.decrypt(json: json, key: key)
        
        if let decryptedData {
            print("Result: " + String(data: decryptedData, encoding: .utf8)!)
        } else {
            print("Decryption failed!")
        }
    }
    
    @IBAction func ButtonAction_Encrypt(_ sender: Any) {
        let plaintext = tv_enc_PlainText.text.data
        let key = tv_enc_SecretKey.text.decodeBase64URLData() // NOTE: The key string must be base64 encoded!
        
        do {
            let jsonString: String = try JWE.encrypt(plaintext: plaintext, keyData: key).str as String
            
            tv_enc_Result.text = jsonString.encodeBase64URL()
            tv_dec_EncryptedJSON.text = jsonString.encodeBase64URL()
        } catch {
            var msg = "-1"
            
            if let err = error as? AESError {
                msg = "( AESError: \(err))"
            } else if let err = error as? HMACError {
                msg = "( HMACError: \(err))"
            }
            
            showMessageView(InfoMessages.errorOccured + msg, duration: 3)
        }
    }
    
    @IBAction func ButtonAction_Decrypt(_ sender: Any) {
        do {
            let isInputBase64Encoded = sw_dec_DecodeBase64.isOn
            var jsonString: String = ""
            
            if isInputBase64Encoded { // decode as base64 from the callback
                jsonString = tv_dec_EncryptedJSON.text.decodeBase64URL()
            } else {
                jsonString = tv_dec_EncryptedJSON.text
            }

            let json: JWEJSON = try JWEJSON(jsonString: jsonString)
            let key = tv_dec_SecretKey.text.decodeBase64URLData() // NOTE: The key string must be base64 encoded!
            
            let decryptedData = try JWE.decrypt(json: json, key: key)
            
            tv_dec_Result.text = String(data: decryptedData, encoding: .utf8)!
        } catch {
            var msg: String = "\(error)"
            
            if let err = error as? AESError {
                msg = "( AESError: \(err))"
            } else if let err = error as? HMACError {
                msg = "( HMACError: \(err))"
            }
            
            showMessageView(InfoMessages.errorOccured + msg, duration: 3)
        }
    }
    
    @IBAction func ButtonAction_CopyEncryption(_ sender: Any) {
        UIPasteboard.general.string = tv_enc_Result.text
        showMessageView(InfoMessages.copySuccess)
    }
    
    @IBAction func ButtonAction_CopyDecryption(_ sender: Any) {
        UIPasteboard.general.string = tv_dec_Result.text
        showMessageView(InfoMessages.copySuccess)
    }
    
    private func showMessageView(_ message: String, duration: TimeInterval = 1.0) {
        let animationSpeed = 0.5
        
        self.l_InfoMessage.text = message
        
        UIView.animate(withDuration: animationSpeed, delay: 0, options: .curveEaseInOut) {
            self.view_message.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: animationSpeed, delay: duration) {
                self.view_message.alpha = 0
            }
        }
    }
}

