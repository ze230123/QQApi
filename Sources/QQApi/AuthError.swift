//
//  AuthError.swift
//  
//
//  Created by youzy01 on 2021/11/15.
//

import Foundation

/// 授权错误
public enum AuthError: Error {
    /// 用户取消
    case cancel
    /// 授权失败
    case failed
    /// 网络异常
    case network
}

extension AuthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancel:
            return "取消登录"
        case .failed:
            return "登录失败"
        case .network:
            return "网络异常"
        }
    }
}
