

import QQSDK

public typealias AuthResult = Result<String, AuthError>
public typealias QQLoginComplation = (AuthResult) -> Void
public typealias QQShareComplation = (ShareResult) -> Void

public enum ShareResult {
    case success
    case failure
}

public final class QQApi: NSObject {
    static var shared: QQApi!

    /// QQ 授权
    var oAuth: TencentOAuth?

    var loginComplation: QQLoginComplation?
    var shareComplation: QQShareComplation?

    init(appId: String) {
        super.init()
        oAuth = TencentOAuth(appId: appId, andDelegate: self)
    }

    func login(complation: QQLoginComplation?) {
        loginComplation = complation
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        oAuth?.authorize(permissions)
    }

    func sendQQ(req: QQBaseReq, complation: QQShareComplation?) {
        shareComplation = complation
        QQApiInterface.send(req)
    }

    func sendQZone(req: QQBaseReq, complation: QQShareComplation?) {
        shareComplation = complation
        QQApiInterface.sendReq(toQZone: req)
    }
}

public extension QQApi {
    /// 注册QQSDK
    /// - Parameter appId: QQ注册的APP id
    static func register(for appId: String) {
        TencentOAuth.setIsUserAgreedAuthorization(true)
        shared = QQApi(appId: appId)
    }

    static func login(complation: QQLoginComplation?) {
        shared.login(complation: complation)
    }

    static func shareQQ(req: QQBaseReq, complation: QQShareComplation?) {
        shared.sendQQ(req: req, complation: complation)
    }

    static func shareQZone(req: QQBaseReq, complation: QQShareComplation?) {
        shared.sendQZone(req: req, complation: complation)
    }

    static func handleOpen(_ url: URL) -> Bool {
        if TencentOAuth.canHandleOpen(url) {
            return TencentOAuth.handleOpen(url)
        }
        return QQApiInterface.handleOpen(url, delegate: shared)
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

extension QQApi: QQApiInterfaceDelegate {
    public func onReq(_ req: QQBaseReq!) {

    }

    public func onResp(_ resp: QQBaseResp!) {
        if resp is SendMessageToQQResp {
            if resp.type == 2 {
                switch resp.result {
                case "0":
                    shareComplation?(.success)
                default:
                    shareComplation?(.failure)
                }
            }
        }
    }

    public func isOnlineResponse(_ response: [AnyHashable : Any]!) {

    }
}

public extension QQApi {
    static func shareRequest(url: String, title: String, description: String, imageData: Data?) -> SendMessageToQQReq {
        let obj = QQApiNewsObject(
            url: URL(string: url),
            title: title,
            description: description,
            previewImageData: imageData,
            targetContentType: .news
        )

        return SendMessageToQQReq(content: obj)
    }

    static func imageRequest(imageData: Data) -> SendMessageToQQReq {
        let obj = QQApiImageObject(data: imageData, previewImageData: imageData, title: nil, description: nil)
        return SendMessageToQQReq(content: obj)
    }
}
