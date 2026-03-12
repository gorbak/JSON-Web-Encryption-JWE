extension Error {
    var message: String {
        var msg: String = "\(self)"
        
        if let err = self as? AESError {
            msg = "( AESError: \(err))"
        } else if let err = self as? HMACError {
            msg = "( HMACError: \(err))"
        }
        
        return msg
    }
}
