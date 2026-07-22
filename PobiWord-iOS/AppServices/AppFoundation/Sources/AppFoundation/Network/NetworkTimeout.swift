//
//  STNetwork
//
//

import Foundation
import Alamofire

nonisolated public class NetworkTimeout: RequestAdapter, @unchecked Sendable {
    private let timeoutInterval: TimeInterval
    
    public init(timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        adaptedRequest.timeoutInterval = timeoutInterval
        completion(.success(adaptedRequest))
    }
}
