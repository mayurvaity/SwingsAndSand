//
//  ItemInfoView.swift
//  SwingsAndSand
//
//  Created by Mayur Vaity on 28/07/24.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    
    //var to keep lookAroundScene data
    @State private var lookAroundScene: MKLookAroundScene?
    
    //var to receive selectedResult data
    var selectedResult: MKMapItem
    
    //var to receive route data
    var route: MKRoute?
    
    //fn to get lookAroundScene data
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
    
    //format travel time for display
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    var body: some View {
        //to show lookAroundScene
        LookAroundPreview(initialScene: lookAroundScene)
            //on top of it placename and time to get there at bottom trailing corner
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                    
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            //the view will get fresh lookAroundScene data by calling blw fn, when appear
            .onAppear {
                getLookAroundScene()
            }
            //also when there is change in selected marker blw code will exec to fetch fresh lookAroundScene data
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
}

//#Preview {
//    ItemInfoView()
//}
