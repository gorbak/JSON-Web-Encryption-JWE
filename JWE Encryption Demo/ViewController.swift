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
        setupGestureRecognizers()
    }
    
    // MARK: - Keyboard dismissal
    func setupGestureRecognizers() {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: Private Utils
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

    private func encrypt() {
        let plaintext = tv_enc_PlainText.text ?? ""
        let key = tv_enc_SecretKey.text ?? ""
        
        do {
            let result = try EncryptionHelper.encrypt(plaintext: plaintext,
                                                      key: key)
            
            tv_enc_Result.text = result
            tv_dec_EncryptedJSON.text = result
        } catch {
            showMessageView(InfoMessages.errorOccured + error.message, duration: 3)
        }
    }

    private func decrypt() {
        do {
            let input = tv_dec_EncryptedJSON.text ?? ""
            let key = tv_dec_SecretKey.text ?? "" // NOTE: The key string must be base64 encoded!
            
            let result = try EncryptionHelper.decrypt(input: input,
                                                      key: key,
                                                      isBase64Encoded: sw_dec_DecodeBase64.isOn)
            
            tv_dec_Result.text = result
        } catch {
            showMessageView(InfoMessages.errorOccured + error.message, duration: 3)
        }
    }
}

extension ViewController { // IBaction extension
    @IBAction func returnPressed(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func ButtonAction_Encrypt(_ sender: Any) {
        encrypt()
    }
    
    @IBAction func ButtonAction_Decrypt(_ sender: Any) {
        decrypt()
    }
    
    @IBAction func ButtonAction_CopyEncryption(_ sender: Any) {
        UIPasteboard.general.string = tv_enc_Result.text
        showMessageView(InfoMessages.copySuccess)
    }
    
    @IBAction func ButtonAction_CopyDecryption(_ sender: Any) {
        UIPasteboard.general.string = tv_dec_Result.text
        showMessageView(InfoMessages.copySuccess)
    }
}

