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

//coordinate region for boston city and north shore
extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.360256,
            longitude: -71.057279),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
    )
    
    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
}

struct ContentView: View {
    
    //to track the position when user has move the map view
    @State private var position: MapCameraPosition = .automatic
    
    //state to track the region that's visible on the map
    @State private var visibleRegion: MKCoordinateRegion?
    
    //to keep searchresults data
    @State private var searchResults: [MKMapItem] = []
    
    //var to store selected marker data
    @State private var selectedResult: MKMapItem?
    
    //var to store route data
    @State private var route: MKRoute?
    
    
    var body: some View {
        //passing tracked position to the map initializer
        //selection - to store selected marker data in selectedResult var, bcoz of this when selected a marker it gets bigger 
        Map(position: $position, selection: $selectedResult) {
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
            .annotationTitles(.hidden) //to hide names of the markers 
            
            //to show user's current location on the map
            UserAnnotation()
            
            //if route data is available, to display route on the map to selectedResult marker
            if let route {
                //to draw line on map
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5) //line shape details
                
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
                
                VStack(spacing: 0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    
                    //search buttons
                    BeantownButtons(position: $position,
                                    searchResults: $searchResults,
                                    visibleRegion: visibleRegion
                    )
                    .padding(.top)
                }
                    
                Spacer()
            }
            .background(.thinMaterial) //to make buttons bg semi-transparent
        }
        //when searchresults are changed, below code to set camera position accordingly
        .onChange(of: searchResults) {
            position = .automatic
        }
        //to get route data everytime marker selection has changed
        .onChange(of: selectedResult) {
            getDirections()
        }
        //modifier to get data of visible region
        //this modifier will collect visible region data once user stop interacting w the map
        //to get constatnt changes to visible region (w/o user stopping), we can specify frequency parameter 
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        //to show map controls (buttons)
        .mapControls {
            //button when clicked it shows user's current location
            MapUserLocationButton()
            //shows compass on screen, when map is rotated by the user
            MapCompass()
            //shows zoom scale on map when user zooms in/ out on the map
            MapScaleView()
        }
    }
    
    
    //fn to get route information
    func getDirections() {
        route = nil  //clearing data in route var
        guard let selectedResult else { return } //no need to get route if selectedResult is NA
        
        //creating request to get route
        let request = MKDirections.Request()
        //specifying starting point of the route
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .parking))
        //specifying destination
        request.destination = selectedResult
        
        Task {
            //getting directions using abv created request
            let directions = MKDirections(request: request)
            //getting route information from directions
            let response = try? await directions.calculate()
            //getting 1st route from obtained list of routes
            route = response?.routes.first
        }
    }
    
}

#Preview {
    ContentView()
}
