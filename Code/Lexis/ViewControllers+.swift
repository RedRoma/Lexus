//
//  ViewControllers+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/17/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemySwift
import CoreLocation
import Foundation
import UIKit

extension UIViewController
{
    
    func hideNetworkIndicator()
    {
        onMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func showNetworkIndicator()
    {
        onMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    var supportsForceTouch: Bool
    {
        guard let view = self.view else { return false }
        return view.traitCollection.forceTouchCapability == .available
    }
}

extension UITableViewController
{
    
    func reloadSection(_ section: Int, withAnimation animation: UITableView.RowAnimation = .automatic)
    {
        let indexSet = IndexSet.init(integer: section)
        self.tableView.reloadSections(indexSet, with: animation)
    }
}

