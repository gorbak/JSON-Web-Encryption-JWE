import UIKit

extension ArraySlice {
    var array: [Element] {
        Array(self)
    }
    
    var data: Data {
        Data(bytes: self.array, count: self.array.count)
    }
}

extension Array {
    var data: Data {
        Data(bytes: self, count: self.count)
    }
    
    func splitComponents() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: leftSplit.array, right: rightSplit.array)
    }
    
    func splitComponentsAsData() -> (left: Data, right: Data) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: leftSplit.data, right: rightSplit.data)
    }
}
