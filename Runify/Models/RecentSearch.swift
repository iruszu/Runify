//
//  RecentSearch.swift
//  Runify
//
//  Created by Kellie Ho on 2025-10-13.
//

import Foundation
import CoreLocation

struct RecentSearch: Codable, Identifiable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.coordinate = coordinate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

