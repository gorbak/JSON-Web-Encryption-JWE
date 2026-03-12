public enum CustomError: Error {
    case invalidBiometrics
    case genericError
    case parsingError
    case encryptionError
    case networkRequestError
    case keyRetrievalError
    case accessTokenError
    case decodingFailed
}
