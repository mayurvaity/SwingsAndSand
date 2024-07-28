//
//  ContentView.swift
//  SwingsAndSand
//
//  Created by Mayur Vaity on 28/07/24.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    //parking loc var
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

struct ContentView: View {
    
    //to track the position when user has move the map view
    @State private var position: MapCameraPosition = .automatic
    
    //to keep searchresults data
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        //passing tracked position to the map initializer
        Map(position: $position) {
            //to create a marker (pin on map) to location of parking var
//            Marker("Parking", coordinate: .parking)
            
            //to display custom swiftui (using zstack) instead of marker abv
            Annotation("Parking", coordinate: .parking) {
                //create car in a rounded rectangle vw on map
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 5)
                    Image(systemName: "car")
                        .padding(5)
                }
            }
            .annotationTitles(.hidden) //to hide the title text on map
            
            //to show results of search (when clicked on search buttons below safeAreaInset)
            ForEach(searchResults, id: \.self) { result in
                //creating marker for each search result
                //this way marker take default styling and naming from MKMapItem results
                Marker(item: result)
            }
        }
        //mapStyle .standard - to specify map style
        //.hybrid - this map style combines .imagery (real) with labels 
        //elevation: .realistic - to see 3d effects
        .mapStyle(.standard(elevation: .realistic))
        //to add buttons abv the map and at the bottom of the screen
        //safeAreaInset - this doesn't obscure any controls of the map 
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                //search buttons
                BeantownButtons(searchResults: $searchResults)
                    .padding(.top)
                
                Spacer()
            }
            .background(.thinMaterial) //to make buttons bg semi-transparent
        }
        //when searchresults are changed, below code to set camera position accordingly
        .onChange(of: searchResults) {
            position = .automatic
        }
    }
}

#Preview {
    ContentView()
}
