//
//  ViewController.swift
//  NetworkServiceExamples
//
//  Created by Christoph Pageler on 04.07.18.
//  Copyright © 2018 the peak lab. gmbh & co. kg. All rights reserved.
//


import UIKit
import NetworkService


class ViewController: UIViewController {

    let networkService = NetworkService()
    var services: [(NetService, String?)] = []

    @IBOutlet weak var tableViewServices: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        networkService.startPublish(type: .http,
                                    name: "Service from iOS App",
                                    port: 1234)

        networkService.isAutoResolveEnabled = true
        networkService.delegate = self
        networkService.startBrowse(type: .http)
    }

    func updateServices(_ service: NetService,
                        withAddress: String? = nil) {
        if let indexOfExistingService = services.index(where: { $0.0 == service}) {
            services[indexOfExistingService] = (service, withAddress)
        } else {
            services.append((service, withAddress))
        }

        tableViewServices.reloadData()
    }

}


extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)

        let service = services[indexPath.row]
        cell.textLabel?.text = service.0.name
        cell.detailTextLabel?.text = service.1

        return cell
    }

}


extension ViewController: NetworkServiceDelegate {

    func networkService(_ networkService: NetworkService,
                        didFind service: NetService,
                        moreComing: Bool,
                        didStartResolve: Bool) {
        updateServices(service)
    }

    func networkService(_ networkService: NetworkService,
                        didResolve service: NetService,
                        address: String) {
        updateServices(service, withAddress: address)
    }

    func networkService(_ networkService: NetworkService,
                        failedToExtractAddressFrom service: NetService) {
        updateServices(service)
    }

}
