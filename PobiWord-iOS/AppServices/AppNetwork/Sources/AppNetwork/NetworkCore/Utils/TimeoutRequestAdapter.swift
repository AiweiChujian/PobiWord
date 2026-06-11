//
//  File.swift
//  STNetwork
//
//  Created by 唐海 on 4/29/25.
//

import Foundation
import Alamofire

public class TimeoutRequestAdapter: RequestAdapter, @unchecked Sendable {
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

