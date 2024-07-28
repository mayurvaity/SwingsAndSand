//
//  BeantownButtons.swift
//  SwingsAndSand
//
//  Created by Mayur Vaity on 28/07/24.
//

import SwiftUI
import MapKit

struct BeantownButtons: View {
    //var to store search results
    @Binding var searchResults: [MKMapItem]
    
    var body: some View {
        //MARK: - Search buttons
        HStack {
            Button {
                search(for: "playground")
            } label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                search(for: "beach")
            } label: {
                Label("Beaches", systemImage: "beach.umbrella")
            }
            .buttonStyle(.borderedProminent)
        }
        .labelStyle(.iconOnly) //to show only icons in abv created buttons and not text
    }
    
    //MARK: - search functions & search results binding
    func search(for query: String) {
        //creating request to call searching fn
        let request = MKLocalSearch.Request()
        //feeding search text to the request
        request.naturalLanguageQuery = query
        //defining result types
        request.resultTypes = .pointOfInterest
        //specifying area to search within
        //center - center of the search area
        //span - width and height of map region
        request.region = MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
            )
        
        //need to call async fn from within a task
        Task {
            //creating search obj using request abv created
            let search = MKLocalSearch(request: request)
            //getting response from search
            let response = try? await search.start()
            
            //getting mapItems data from response and keeping them in our local array
            searchResults = response?.mapItems ?? []
        }
    }
    
}



//#Preview {
//    BeantownButtons(searchResults: .constant(<#T##value: [MKMapItem]##[MKMapItem]#>))
//}
