//
//  MapView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 4/26/24.
//

import Foundation
import SwiftUI
import MapKit

struct MapView : View {

    private let geocoder = CLGeocoder()
    @State private var position : MapCameraPosition = .automatic
    @State private var selectedResult: Int?
    @State var expenses : [ExpenseEntity] = []
    @State private var mapItems: [(Int, MKMapItem)] = []
    @State private var selected: Bool = false
    
    var body: some View {
        Map(position: $position, selection: $selectedResult) {
            // for each item in list of items make a marker
            //
            ForEach(mapItems, id: \.0) { uuid, mapItem in
                Marker(item: mapItem)
                .tag(uuid)
            }
        }
        .task {
            await self.calculateMapItems()
        }
        .onChange(of: selectedResult) {
            selected.toggle()
        }
        .navigationDestination(isPresented: $selected) {
            
        }
    }
    
    func calculateMapItems() async {
        mapItems = []
        for (idx, element) in expenses.enumerated() {
            guard let location = element.location else {
                continue
            }
            do {
                let coordinates = try await getCoordinates(address: location)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                mapItem.name = element.name
                mapItems.append((idx, mapItem))
            } catch {
                print("Error grabbing coordinates for item \(idx) at \(location): \(error)")
            }
        }
    }

    func getCoordinates(address: String) async throws -> CLLocationCoordinate2D {
        print("Grabbing coordinates for \(address)")
        //CLGeocoder not finding Annapolis,MD
        let placemark = try await self.geocoder.geocodeAddressString(address)
        return placemark[0].location!.coordinate
    }
}

