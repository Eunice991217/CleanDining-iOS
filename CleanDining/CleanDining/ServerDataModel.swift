//
//  ServerDataModel.swift
//  CleanDining
//
//  Created by 김민경 on 2023/06/23.
//

import Foundation

// MARK: - DataModelElement
struct DataModelElement: Codable {
    let id: Int
    let name: String
    let type: String
    let latitude, longitude: Double
    let address: String
}

typealias DataModel = [DataModelElement]

