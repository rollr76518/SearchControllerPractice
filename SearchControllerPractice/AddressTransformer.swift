//
//  AddressTransformer.swift
//  SearchControllerPractice
//
//  Created by Ryan on 2016/12/10.
//  Copyright © 2016年 Hanyu. All rights reserved.
//

import UIKit
import MapKit

class AddressTransformer: NSObject {
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
               let addressLine = String(
            format:"%@%@%@%@",
            // state
            selectedItem.administrativeArea ?? "",
            // city
            selectedItem.locality ?? "",
            // street name
            selectedItem.thoroughfare ?? "",
            // street number
            (selectedItem.subThoroughfare != nil) ? String.init(format: "%@號", selectedItem.subThoroughfare!):""
        )
        return addressLine
    }
}
