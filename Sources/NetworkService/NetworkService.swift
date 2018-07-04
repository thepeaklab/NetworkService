//
//  NetworkService.swift
//  NetworkService
//
//  Created by Christoph Pageler on 27.06.18.
//


@_exported import Foundation


public class NetworkService: NSObject {

    /// ServiceType is an enum which encapsulates some available dns service types
    ///
    /// - see: http://www.dns-sd.org/servicetypes.html
    public enum ServiceType {
        case http

        case tcp(name: String)
        case udp(name: String)

        /// Converts ServiceType to dns String
        ///
        /// - Returns: String for current type
        public func stringValue() -> String {
            switch self {
            case .http:
                return ServiceType.tcp(name: "http").stringValue()
            case .tcp(let name):
                return "_\(name)._tcp."
            case .udp(let name):
                return "_\(name)._udp."
            }
        }

    }

    private var service: NetService?
    private var isServicePublishing: Bool

    private let serviceBrowser = NetServiceBrowser()
    private var isServiceBrowserSearching: Bool

    private var servicesToResolve: [NetService] = []

    public weak var delegate: NetworkServiceDelegate?

    public var isAutoResolveEnabled: Bool = false

    
    public override init() {
        self.isServicePublishing = false
        self.isServiceBrowserSearching = false

        super.init()

        self.delegate = nil
        self.serviceBrowser.delegate = self
    }

    // MARK: - Publish

    public func startPublish(_ service: NetService) {
        stopPublish()

        service.delegate = self
        service.publish()

        isServicePublishing = true

        self.service = service
    }

    public func startPublish(domain: String = "local.",
                             type: ServiceType,
                             name: String,
                             port: Int32) {
        startPublish(NetService(domain: domain,
                                type: type.stringValue(),
                                name: name,
                                port: port))
    }

    public func isPublishing() -> Bool {
        return service != nil && isServicePublishing
    }

    public func stopPublish() {
        service?.stop()
        service = nil

        isServicePublishing = false
    }

    // MARK: - Browse

    public func startBrowse(domain: String = "local.",
                            type: ServiceType) {
        stopBrowse()
        serviceBrowser.searchForServices(ofType: type.stringValue(),
                                         inDomain: domain)
        isServiceBrowserSearching = true
    }

    public func stopBrowse() {
        serviceBrowser.stop()
        isServiceBrowserSearching = false
    }

    public func isBrowsing() -> Bool {
        return isServiceBrowserSearching
    }

    // MARK: - Resolve

    public func startResolve(_ service: NetService, withTimeout timeout: TimeInterval = 30) {
        servicesToResolve.append(service)
        service.delegate = self
        service.resolve(withTimeout: timeout)
    }

    private func cleanResolve(_ service: NetService) {
        guard let indexOfService = servicesToResolve.index(of: service) else { return }
        servicesToResolve.remove(at: indexOfService)
    }

    private func extractAddress(from service: NetService) -> String? {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = service.addresses?.first else { return nil }
        do {
            try data.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                    throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
                }
            }
        } catch {
            print(error)
            return nil
        }
        return String(cString:hostname)
    }

}

// MARK: - NetServiceDelegate

extension NetworkService: NetServiceDelegate {

    public func netServiceWillPublish(_ sender: NetService) {
        delegate?.networkService(self, willPublish: sender)
    }

    public func netServiceDidPublish(_ sender: NetService) {
        delegate?.networkService(self, didPublish: sender)
    }

    public func netService(_ sender: NetService,
                           didNotPublish errorDict: [String : NSNumber]) {
        delegate?.networkService(self, didNotPublish: sender)
    }

    public func netServiceWillResolve(_ sender: NetService) {
        delegate?.networkService(self, willResolve: sender)
    }

    public func netServiceDidResolveAddress(_ sender: NetService) {
        if let address = extractAddress(from: sender) {
            delegate?.networkService(self, didResolve: sender, address: address)
        } else {
            delegate?.networkService(self, failedToExtractAddressFrom: sender)
        }
        cleanResolve(sender)
    }

    public func netService(_ sender: NetService,
                           didNotResolve errorDict: [String : NSNumber]) {
        delegate?.networkService(self, didNotResolve: sender)
        cleanResolve(sender)
    }

    public func netServiceDidStop(_ sender: NetService) {
        delegate?.networkService(self, didStop: sender)
        cleanResolve(sender)
    }

}

// MARK: - NetServiceBrowserDelegate

extension NetworkService: NetServiceBrowserDelegate {

    public func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {

    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {

    }

    public func netServiceBrowser(_ browser: NetServiceBrowser,
                                  didNotSearch errorDict: [String : NSNumber]) {

    }

    public func netServiceBrowser(_ browser: NetServiceBrowser,
                                  didFindDomain domainString: String, moreComing: Bool) {

    }

    public func netServiceBrowser(_ browser: NetServiceBrowser,
                                  didFind service: NetService,
                                  moreComing: Bool) {
        if isAutoResolveEnabled {
            startResolve(service)
        }

        delegate?.networkService(self, didFind: service, moreComing: moreComing, didStartResolve: isAutoResolveEnabled)
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser,
                                  didRemoveDomain domainString: String,
                                  moreComing: Bool) {

    }

    public func netServiceBrowser(_ browser: NetServiceBrowser,
                                  didRemove service: NetService,
                                  moreComing: Bool) {

    }

}
