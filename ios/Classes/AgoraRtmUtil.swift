//
//  AgoraRtmUtil.swift
//  agora_wrapper
//
//  Created by cy on 2024/4/16.
//



import Foundation
import AgoraRtmKit

class AgoraRtmUtil:NSObject, AgoraRtmDelegate {
    static let shared = AgoraRtmUtil()
    
    var appId:String = "";
    var rtmToken:String = "";
    var uid:String = "";
    
    var channel:AgoraRtmChannel?
    
    private override init() {
    }
    
    lazy var rtm: AgoraRtmKit? = {
        let kit = AgoraRtmKit(appId: appId, delegate: self)
        kit?.setLogFile(FileManager.cacheRTMLog())
        return kit
    }()
    
    func loginRtm(appId:String?,rtmToken:String?,uid:String?) {
        self.appId = appId ?? ""
        self.rtmToken = rtmToken ?? ""
        self.uid = uid ?? ""
        rtm?.login(byToken: self.rtmToken, user: self.uid, completion: { (result) in
            
        })
    }
    
    func joinRtmChannel(roomId: String) -> String {
        channel = rtm?.createChannel(withId: roomId, delegate: self)
        channel?.join()
        return ""
    }
    
    func leaveRtmChannel() {
        channel?.leave()
    }
    
    func sendMessageChannel(message:String)  {
        channel?.send(AgoraRtmMessage(text: message))
    }
    
}


extension AgoraRtmUtil: AgoraRtmChannelDelegate {
    /// receive a message p-2-p
    /// - Parameters:
    ///   - kit: kit description
    ///   - message: message description
    ///   - peerId: peerId description
    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        //        receiveRTMMessage(message: message)
    }
    
    /// receive group message
    /// - Parameters:
    ///   - channel: channel description
    ///   - message: message description
    ///   - member: member description
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        //        receiveRTMMessage(message: message)
    }
    
    /// connection state
    /// - Parameters:
    ///   - kit: kit description
    ///   - state: state description
    ///   - reason: reason description
    func rtmKit(_ kit: AgoraRtmKit, connectionStateChanged state: AgoraRtmConnectionState, reason: AgoraRtmConnectionChangeReason) {
        
    }
}



extension FileManager {
    public static func tempDirectory(with pathComponent: String = ProcessInfo.processInfo.globallyUniqueString) throws -> URL {
        var tempURL: URL
        let cacheURL = FileManager.default.temporaryDirectory
        if let url = try? FileManager.default.url(for: .itemReplacementDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: cacheURL,
                                                  create: true) {
            tempURL = url
        } else {
            tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        }
        
        tempURL.appendPathComponent(pathComponent)
        
        if !FileManager.default.fileExists(atPath: tempURL.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
                return tempURL
            } catch {
                throw error
            }
        } else {
            return tempURL
        }
    }
    
    public static func cacheVideo() -> URL?{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/voya_cache_video"
        var cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                cacheURL = nil
            }
        }
        return cacheURL
    }
    public static func cacheSVGA() -> URL?{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/voya_cache_svga"
        var cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                cacheURL = nil
            }
        }
        return cacheURL
    }
    public static func cacheLog() -> URL?{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/voya_cache_log"
        var cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                cacheURL = nil
            }
        }
        return cacheURL
    }
    public static func cacheZip() -> URL?{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/zip"
        var cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                cacheURL = nil
            }
        }
        
        return cacheURL
    }
    
    /**
     * 当 agorasdk.log 写满后，SDK 会按照以下顺序对日志文件进行操作：
     * 删除 agorasdk.4.log 文件（如有）。
     * 将agorasdk.3.log 重命名为 agorasdk.4.log。
     * 将agorasdk.2.log 重命名为 agorasdk.3.log。
     * 将agorasdk.1.log 重命名为 agorasdk.2.log。
     * 新建 agorasdk.log 文件。
     * https://docportal.shengwang.cn/cn/live-streaming-premium-4.x/API%20Reference/java_ng/API/toc_network.html?platform=Android#api_irtcengine_setlogfilesize
     *
     * @param i
     * @return
     */
    public static func cacheRTCLog() -> String{
        return cacheRTCPath() + "/agorartc.log"
    }
    public static func cacheRTCPath() -> String{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/Caches/voya_cache_rtc"
        let cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        return file
    }
    public static func cacheRTMLog() -> String{
        return cacheRTMPath() + "/agorartm.log"
    }
    public static func cacheRTMPath() -> String{
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let file =  documentDirectory + "/Caches/voya_cache_rtm"
        var cacheURL:URL? = URL(fileURLWithPath: file)
        if !FileManager.default.fileExists(atPath:file)  {
            do {
                try FileManager.default.createDirectory(at: cacheURL!, withIntermediateDirectories: true, attributes: nil)
            } catch {
            }
        }
        return file
    }
    // 获取文件夹文件
    public static func getFilesInFolder(atPath path: String) -> [String] {
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: path)
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            let files = fileURLs.map { $0.lastPathComponent }
            return files
        } catch {
            print("获取文件夹中的文件时发生错误：\(error)")
            return []
        }
    }
    
}

