//
//  TTNet.swift
//  Yuhun
//
//  Created by Mr.hong on 2020/11/25.
//

import Foundation
import RxSwift
import Alamofire
import SwifterSwift
import SwiftyJSON
import HandyJSON


// 初始化的时候,传入服务器制定的网络编码规则
class TTNetManager: NSObject {
    static let shared = TTNetManager()
    
    // domain域名
    var domain = ""
    
    // data的Key 默认data
    var dataKey = "data"
    
    // 请求结果代码key默认code
    var codeKey = "code"
    
    // 消息key默认message
    var messageKey = "message"
    
    // 消息key默认message
    var errorMessageKey = "error_message"
    
    // 成功code，默认200
    var successCode = 200
    
    // 默认需要添加参数
    var defaultParams: [String : Any]?
    
    // 网络请求token
    var token =  ""
    
    // 初始化超时时间，默认10秒
    var timeOutInterval = 10.0
    
    // 授权头关键词
    var authorizationWords = ""
    
    // 拦截器
//    var interceptor: TTNetInterceptor?
    
    
    // 无需token的api
    var doNotNeedTokenApi = [""]
    
    lazy var interceptor2: AuthenticationInterceptor<OAuthAuthenticator> = {
        // Generally load from keychain if it exists
        let credential = OAuthCredential()

        // Create the interceptor
        let authenticator = OAuthAuthenticator()
    
        let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential, refreshWindow: .init(interval: TTNetManager.shared.timeOutInterval, maximumAttempts: 1))
        return interceptor
    }()
    
    
    // 头部
    var headers: HTTPHeaders {
        get {
            return  [
                "Accept" : "application/json",
                "sn-common": "version=\(AppVersion)&app=20200901&channel=app_store"
            ]
        }
    }
    
    // 服务器时间,为本地时间戳 * 1000
    var serverTime: TimeInterval = Date().timeIntervalSince1970 * 1000.0
    
    // 网络监听
    var networkManager: NetworkReachabilityManager!
    
    // 网络状态
    var netStatus = NetworkReachabilityManager.NetworkReachabilityStatus.unknown
    {
        didSet {
            netStatutsSingle.onNext(self.netStatus)
        }
    }
    
    // 网络状态信号
    let netStatutsSingle = PublishSubject<NetworkReachabilityManager.NetworkReachabilityStatus>()
    
    
    // 网络请求成功结果全局传出去
//    let responseSuccessSingle = PublishSubject<(AFDataResponse<Any>,TTNetModel)>()
    
    
    // 网络请求失败结果全局传出去
    let responseFailSingle = PublishSubject<(AFDataResponse<Any>,TTNetModel)>()
    
    // 是否打开log
    var openLog: Bool{
        
        #if DEBUG
        return true
        #endif
        
        return false
    }
    
    // 初始化网络配置
    func setupNetConfigure(domain: String,codeKey: String = "code",dataKey: String = "data",messageKey: String = "message",successCode: Int,defaultParams: [String : String]? = nil, token: String,authorizationWords: String = "Bearer") {
        self.domain = domain
        self.codeKey = codeKey
        self.dataKey = dataKey
        self.messageKey = messageKey
        self.successCode = successCode
        self.defaultParams = defaultParams
        self.token = token
        self.authorizationWords = authorizationWords
        
        

        // 每秒加服务器时间
        Observable<Int>.timer(RxTimeInterval.seconds(0), period: RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (_) in guard let self = self else { return }
            
            // 服务器时间是时间戳 * 1000,所以步进是1000
            self.serverTime += 1000
        }).disposed(by: rx.disposeBag)
        
        
        networkManager = NetworkReachabilityManager(host: domain)
        networkManager!.startListening { [weak self]  (status) in guard let self = self else { return }
            var message = ""
            switch status {
            case .unknown:
                message = "未知网络,请检查..."
            case .notReachable:
                message = "无法连接网络,请检查..."
            case .reachable(.cellular):
                message = "蜂窝移动网络,注意节省流量..."
            case .reachable(.ethernetOrWiFi):
                message = "WIFI-网络,使劲造吧..."
            }
            
            // 赋值网络状态
            self.netStatus = status
        }
    }
    
    // 更新网络请求token
    func updateToken(token: String) {
        self.token = token;
    }
}

extension TTNetManager {
    // 快速取token
    var accessToken: String {
        return interceptor2.credential?.accessToken ?? ""
    }
    
    var refreshToken: String {
        return interceptor2.credential?.refreshToken ?? ""
    }
    
}

class TTNet: NSObject {
    //MARK: - 请求,根据type来决定请求
    class func requst(type: HTTPMethod = .post, api: String, parameters:[String : Any]? = nil,secret: Bool = false,encoding: ParameterEncoding? = nil) -> Single<TTNetModel> {
        return Single<TTNetModel>.create {(single) -> Disposable in
            
            // 拼接完整api,参数
            let fullApi = TTNetManager.shared.domain + api
            
            // 是否加密，获取完整参数
            let fullParameters = secretParams(sourceParameters: parameters,secret: secret)
            

            // 参数编码
            var encoding: ParameterEncoding = JSONEncoding.default
            if type == .get {
                // get 请求要使用默认编码格式
                encoding = URLEncoding.default
            }
            
     
            AF.request(fullApi,method: type,parameters:fullParameters,encoding: encoding,headers: TTNetManager.shared.headers,interceptor: TTNetManager.shared.doNotNeedTokenApi.contains(api) ? nil : TTNetManager.shared.interceptor2) { request in
                request.timeoutInterval = TTNetManager.shared.timeOutInterval
            }.validate().responseJSON { (response) in
                if TTNetManager.shared.openLog {
                    print("🔥接口\(fullApi) 参数为\(fullParameters)  响应内容为 \(response)\n ------------------------ ")
                }
                
                switch response.error {
                case .sessionInvalidated(_),.explicitlyCancelled:
                    // 网络请求取消了，就不提示处理了
                    return
                default:
                    break
                }
                
                // 处理数据
                self.disposeResponse(single, response,api: fullApi,parameters: fullParameters)
            }
            
            
            return Disposables.create {}
        }.observeOn(MainScheduler.instance)
    }
    
    
//    // 普通post网络请求
//    class func testRequst(api: String, parameters:[String : Any]? = nil,secret: Bool = false,queue: DispatchQueue,specialCodeModifier: RequestSpecialCodeModifier? = nil,encoding: ParameterEncoding = JSONEncoding()) -> Single<TTNetModel> {
//        return Single<TTNetModel>.create {(single) -> Disposable in
//
//
//            // 拼接完整api,参数
//            let fullApi = TTNetManager.shared.domain + api
//
//            // 是否加密，获取完整参数
//            let fullParameters = secretParams(sourceParameters: parameters,secret: secret)
//
//
//            // 参数编码
//            var encoding: ParameterEncoding = JSONEncoding.default
//            // get 请求要使用默认编码格式
//            encoding = URLEncoding.default
//            debugdebugPrint("接口\(fullApi)完整参数为\(fullParameters)")
//
//
//            AF.request(fullApi,method: .get,parameters:fullParameters,encoding: encoding,headers: nil,interceptor: TTNetManager.shared.interceptor){ request in
//                request.timeoutInterval = TTNetManager.shared.timeOutInterval
//            }.validate().response(queue: .global(), completionHandler: { (response) in
//
//
//                // 返回模型
//                var dataModel = TTNetModel.init()
//
//                single(.success(dataModel))
//                debugPrint("11111111")
//                debugPrint(response)
//            }).responseJSON { (response) in
//                // 处理数据
//                self.disposeResponse(single, response,api: api,parameters: parameters,specialCodeModifier: specialCodeModifier)
//            }
//            return Disposables.create {}
//        }.observeOn(MainScheduler.instance)
//    }
    
    
    // 普通post网络请求
//    class func normalrequst(api: String, parameters:[String : Any]? = nil,secret: Bool = false,specialCodeModifier: RequestSpecialCodeModifier? = nil,encoding: ParameterEncoding = JSONEncoding()) -> Single<TTNetModel> {
//        return Single<TTNetModel>.create {(single) -> Disposable in
//
//            AF.request(api,method: .post,parameters:parameters,encoding: encoding,headers: nil,interceptor: TTNetManager.shared.interceptor){ request in
//                request.timeoutInterval = TTNetManager.shared.timeOutInterval
//            }.validate().responseJSON { (response) in
//                // 处理数据
//                self.disposeResponse(single, response,api: api,parameters: parameters,specialCodeModifier: specialCodeModifier)
//            }
//            return Disposables.create {}
//        }.observeOn(MainScheduler.instance)
//    }
    
    // 处理返回的模型
    class func disposeResponse(_ single: @escaping (SingleEvent<PrimitiveSequence<SingleTrait, TTNetModel>.Element>) ->(), _ response: AFDataResponse<Any>,api: String,parameters: [String : Any]?,needSourceParams: Bool = false) {
        switch response.result {
        case .success:
            
            // 返回模型
            var dataModel = TTNetModel.init()
            
            // 字典转模型
            if let dataDic = response.value as? [String : Any] {

                // 取出对应的data，key，message
                dataModel.data = dataDic[TTNetManager.shared.dataKey] as? [String : Any] ?? [String : Any]()
                dataModel.code = dataDic[TTNetManager.shared.codeKey] as? Int ?? -111111
                dataModel.message = dataDic[TTNetManager.shared.messageKey] as? String ?? ""
                
                
                // 如果需要原始参数
                if needSourceParams {
                    dataModel.sourceParams = parameters
                }
                
                
                // 是否完全请求成功code无异常
                if dataModel.realSuccuss {
                    single(.success(dataModel))
                }else {
                    if TTNetManager.shared.openLog {
                        print("接口报错了🔥🔥🔥\(api)\n 错误信息是: code - \(dataModel.code) - \(dataModel.message)\n 参数是\(String(describing: parameters ?? ["" : ""]))")
                    }
                    single(.error(TTNetError.init(dataModel.message, dataModel.code)))
                }
            }else {
                single(.error(TTNetError.init("模型解析失败了,后台需要检查数据结构")))
            }
            
       
        case .failure:
            // 先判断网络状态
            switch TTNetManager.shared.netStatus {
            case .notReachable,.unknown:
                showHUD("网络连接已断开，请检查网络~")
                single(.error(TTNetError.init("网络连接已断开，请检查网络后点击重新加载~")))
                return
            default:
                break
            }
            
            let dataModel = TTNetModel()
            dataModel.message = "网络报错了,请检查网络或稍后尝试~"
            
            
            
            if let dataDic = response.data?.toDictionary()  {
                // 取出对应的data，key，message
                dataModel.code = dataDic[TTNetManager.shared.codeKey] as? Int ?? -111191
                dataModel.message = dataDic[TTNetManager.shared.errorMessageKey] as? String ?? "网络报错了,请检查网络或稍后尝试~"
            }
            
            
            single(.error(TTNetError.init(dataModel.message,dataModel.code)))
            
            
            // 显示错误信息
            showError(dataModel.message)
            
            // 将每一次成功的请求传出去
            TTNetManager.shared.responseFailSingle.onNext((response,dataModel))
            
        }
    }
    
    // 添加默认传给服务器的参数,与加密相关
    private class func secretParams(sourceParameters: [String : Any]?,secret: Bool) -> [String : Any]? {
        // 加密的话，就加参
        if secret {
            if sourceParameters != nil {
                var finalParamter = sourceParameters;
                finalParamter!["sign"] = self.encryption(paramaters: finalParamter!)
                return finalParamter
            }
        }else {
            return sourceParameters
        }
        return nil
    }
    
    
    //MARK: - 加密操作
    class func encryption(paramaters: [String : Any]) -> String {
        let dic = NSDictionary.init(dictionary: paramaters)
        let keyArray = dic.allKeysSorted()
        var itemsArray = [String]()
        
        for index in 0..<keyArray.count {
            let key = keyArray[index]
            let value = dic[key]!
            itemsArray.append("\(key)=\(value)")
        }
        
        // 最后再拼上一个secret
        itemsArray.append("secret=supernova")
        if itemsArray.count > 0 {
            var sign = itemsArray.joined(separator: "&") as NSString
            
            sign = sign.sha256()! as NSString
            return  sign as String
        }
        return "iOS端网络请求参数加密有错误"
    }
}
