//
//  Coordinator.swift
//  XWallet
//
//  Created by loj on 22.10.17.
//

import Foundation


public protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get set }
    
}


public extension Coordinator {
    
    func add(childCoordinator: Coordinator) {
        if self.childCoordinators.contains(where: { $0 === childCoordinator }) {
            return
        }
        self.childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }
    
}
