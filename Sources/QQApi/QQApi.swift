

import QQSDK

public typealias AuthResult = Result<String, AuthError>
public typealias QQLoginComplation = (AuthResult) -> Void

public final class QQApi: NSObject {
    static var shared: QQApi!

    /// QQ 授权
    var oAuth: TencentOAuth?

    var loginComplation: QQLoginComplation?

    init(appId: String) {
        super.init()
        oAuth = TencentOAuth(appId: appId, andDelegate: self)
    }

    func login(complation: QQLoginComplation?) {
        loginComplation = complation
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        oAuth?.authorize(permissions)
    }
}

public extension QQApi {
    /// 注册QQSDK
    /// - Parameter appId: QQ注册的APP id
    static func register(for appId: String) {
        shared = QQApi(appId: appId)
    }

    static func login(complation: QQLoginComplation?) {
        shared.login(complation: complation)
    }

    static func share() {
    }
}

extension QQApi: TencentSessionDelegate {
    public func tencentDidLogin() {
        let openId = oAuth?.openId ?? ""
        loginComplation?(.success(openId))
    }

    public func tencentDidNotLogin(_ cancelled: Bool) {
        if cancelled {
            loginComplation?(.failure(.cancel))
        } else {
            loginComplation?(.failure(.failed))
        }
    }

    public func tencentDidNotNetWork() {
        loginComplation?(.failure(.network))
    }
}
