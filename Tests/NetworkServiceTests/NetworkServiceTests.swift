//
//  NetworkServiceTests.swift
//  NetworkServiceTests
//
//  Created by Christoph Pageler on 27.06.18.
//


import XCTest
@testable import NetworkService


final class NetworkServiceTests: XCTestCase {

    func testInitialNetworkServiceState() {
        let networkService = NetworkService()
        XCTAssertFalse(networkService.isPublishing())
    }

    func testNetworkServicePublishShouldChangeIsPublishingToTrue() {
        let networkService = NetworkService()
        networkService.startPublish(type: .http, name: "Test Service", port: 1234)
        XCTAssertTrue(networkService.isPublishing())

        networkService.stopPublish()
        XCTAssertFalse(networkService.isPublishing())
    }

    func testStartBrowseShouldFindService() {
        let exp = expectation(description: "expectation")

        let networkService = NetworkService()
        let delegate = NetworkServiceClosureDelegate()
        delegate.didFindService = { service, _, _ in
            if service.name == "Test Service" {
                exp.fulfill()
            }
        }
        networkService.delegate = delegate

        networkService.startPublish(type: .http, name: "Test Service", port: 1234)
        networkService.startBrowse(type: .http)

        waitForExpectations(timeout: 30, handler: nil)
    }

    func testAutoResolveShouldResolveAddressOfService() {
        let exp = expectation(description: "expectation")

        let networkService = NetworkService()
        let delegate = NetworkServiceClosureDelegate()
        delegate.didResolveService = { service, address in
            if service.name == "Test Service" {
                XCTAssertEqual(service.port, 1234)
                exp.fulfill()
            }
        }
        networkService.delegate = delegate
        networkService.isAutoResolveEnabled = true

        networkService.startPublish(type: .http, name: "Test Service", port: 1234)
        networkService.startBrowse(type: .http)

        waitForExpectations(timeout: 30, handler: nil)
    }

    func testManualResolveShouldResolveAddressOfService() {
        let exp = expectation(description: "expectation")

        let networkService = NetworkService()
        let delegate = NetworkServiceClosureDelegate()
        delegate.didFindService = { service, _ , didStartResolve in
            XCTAssertFalse(didStartResolve)
            if service.name == "Test Service" {
                networkService.startResolve(service)
            }
        }
        delegate.didResolveService = { service, address in
            if service.name == "Test Service" {
                XCTAssertEqual(service.port, 1234)
                exp.fulfill()
            }
        }
        networkService.delegate = delegate
        networkService.isAutoResolveEnabled = false

        networkService.startPublish(type: .http, name: "Test Service", port: 1234)
        networkService.startBrowse(type: .http)

        waitForExpectations(timeout: 30, handler: nil)
    }

    static var allTests = [
        ("testInitialNetworkServiceState", testInitialNetworkServiceState),
        ("testNetworkServicePublishShouldChangeIsPublishingToTrue", testNetworkServicePublishShouldChangeIsPublishingToTrue),
        ("testStartBrowseShouldFindService", testStartBrowseShouldFindService),
        ("testAutoResolveShouldResolveAddressOfService", testAutoResolveShouldResolveAddressOfService)
    ]

}
