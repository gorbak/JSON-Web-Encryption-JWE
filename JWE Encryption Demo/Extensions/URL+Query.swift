import UIKit

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

// MARK: NSURLComponents
extension URLComponents {
    var uaf: String {
        return String(path.dropFirst()) // return without the "/" symbol
    }
    
    var queryDictionary: [String: String] {
        get {
            guard let query = self.query else {
                return [:]
            }
            return query.toQueryDictionary
        }
        set {
            if newValue.isEmpty {
                self.query = nil
            } else {
                self.percentEncodedQuery = newValue.queryString
            }
        }
    }

    fileprivate mutating func addToQuery(_ add: String) {
        if let query = self.percentEncodedQuery {
            self.percentEncodedQuery = query + "&" + add
        } else {
            self.percentEncodedQuery = add
        }
    }
}

// MARK: String
extension String {
    public var toQueryDictionary: [String: String] {
        var result: [String: String] = [String: String]()
        let pairs: [String] = self.components(separatedBy: "&")
        for pair in pairs {
            let comps: [String] = pair.components(separatedBy: "=")
            if comps.count >= 2 {
                let key = comps[0]
                let value = comps.dropFirst().joined(separator: "=")
                result[key.queryDecode] = value.queryDecode
            }
        }
        return result
    }

    public var queryEncodeRFC3986: String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)

        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
    }

    var queryEncode: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }

    var queryDecode: String {
        return self.removingPercentEncoding ?? self
    }

}

// MARK: Dictionary
extension Dictionary {
    var queryString: String {
        var parts = [String]()
        for (key, value) in self {
            let keyString = "\(key)".queryEncodeRFC3986
            let valueString = "\(value)".queryEncodeRFC3986
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        return parts.joined(separator: "&") as String
    }

    fileprivate func join(_ other: Dictionary) -> Dictionary {
        var joinedDictionary = Dictionary()

        for (key, value) in self {
            joinedDictionary.updateValue(value, forKey: key)
        }

        for (key, value) in other {
            joinedDictionary.updateValue(value, forKey: key)
        }

        return joinedDictionary
    }

    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] { return left.join(right) }
func &= (left: inout URLComponents, right: String) { left.addToQuery(right) }
