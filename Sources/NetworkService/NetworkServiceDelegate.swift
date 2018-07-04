//
//  NetworkServiceDelegate.swift
//  NetworkService
//
//  Created by Christoph Pageler on 04.07.18.
//


import Foundation


public protocol NetworkServiceDelegate: class {

    // MARK: - Publish

    func networkService(_ networkService: NetworkService, willPublish service: NetService)

    func networkService(_ networkService: NetworkService, didPublish service: NetService)

    func networkService(_ networkService: NetworkService, didNotPublish service: NetService)

    // MARK: - Browse

    func networkService(_ networkService: NetworkService,
                        didFind service: NetService,
                        moreComing: Bool,
                        didStartResolve: Bool)

    // MARK: - Resolve

    func networkService(_ networkService: NetworkService,
                        didResolve service: NetService,
                        address: String)

    func networkService(_ networkService: NetworkService,
                        failedToExtractAddressFrom service: NetService)

    func networkService(_ networkService: NetworkService, willResolve service: NetService)

    func networkService(_ networkService: NetworkService, didNotResolve service: NetService)

    func networkService(_ networkService: NetworkService, didStop service: NetService)

}


public extension NetworkServiceDelegate {

    // MARK: - Publish

    func networkService(_ networkService: NetworkService, willPublish service: NetService) { }

    func networkService(_ networkService: NetworkService, didPublish service: NetService) { }

    func networkService(_ networkService: NetworkService, didNotPublish service: NetService) { }

    // MARK: - Browse

    func networkService(_ networkService: NetworkService,
                        didFind service: NetService,
                        moreComing: Bool,
                        didStartResolve: Bool) { }

    // MARK: - Resolve

    func networkService(_ networkService: NetworkService,
                        didResolve service: NetService,
                        address: String) { }

    func networkService(_ networkService: NetworkService,
                        failedToExtractAddressFrom service: NetService) { }

    func networkService(_ networkService: NetworkService, willResolve service: NetService) { }

    func networkService(_ networkService: NetworkService, didNotResolve service: NetService) { }

    func networkService(_ networkService: NetworkService, didStop service: NetService) { }

}


public class NetworkServiceClosureDelegate: NetworkServiceDelegate {

    public typealias NetServiceClosure = (_ service: NetService) -> Void
    public typealias DidFindServiceClosure = (_ service: NetService, _ moreComing: Bool, _ didStartResolve: Bool) -> Void
    public typealias DidResolveServiceClosure = (_ service: NetService, _ address: String) -> Void

    public var willPublishService: NetServiceClosure?
    public var didPublishService: NetServiceClosure?
    public var didNotPublishService: NetServiceClosure?
    public var didFindService: DidFindServiceClosure?
    public var didResolveService: DidResolveServiceClosure?
    public var failedToExtractAddressService: NetServiceClosure?
    public var willResolveService: NetServiceClosure?
    public var didNotResolveService: NetServiceClosure?
    public var didStopService: NetServiceClosure?

    init() {
        self.willPublishService = nil
        self.didPublishService = nil
        self.didNotPublishService = nil
        self.didFindService = nil
        self.didResolveService = nil
        self.failedToExtractAddressService = nil
        self.willResolveService = nil
        self.didNotResolveService = nil
        self.didStopService = nil
    }

    // MARK: - Publish

    public func networkService(_ networkService: NetworkService, willPublish service: NetService) {
        willPublishService?(service)
    }

    public func networkService(_ networkService: NetworkService, didPublish service: NetService) {
        didPublishService?(service)
    }

    public func networkService(_ networkService: NetworkService, didNotPublish service: NetService) {
        didNotPublishService?(service)
    }

    // MARK: - Browse

    public func networkService(_ networkService: NetworkService,
                               didFind service: NetService,
                               moreComing: Bool,
                               didStartResolve: Bool) {
        didFindService?(service, moreComing, didStartResolve)
    }

    // MARK: - Resolve

    public func networkService(_ networkService: NetworkService,
                               didResolve service: NetService,
                               address: String) {
        didResolveService?(service, address)
    }

    public func networkService(_ networkService: NetworkService,
                               failedToExtractAddressFrom service: NetService) {
        failedToExtractAddressService?(service)
    }

    public func networkService(_ networkService: NetworkService, willResolve service: NetService) {
        willResolveService?(service)
    }

    public func networkService(_ networkService: NetworkService, didNotResolve service: NetService) {
        didNotResolveService?(service)
    }

    public func networkService(_ networkService: NetworkService, didStop service: NetService) {
        didStopService?(service)
    }

}
