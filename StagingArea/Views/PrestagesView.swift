//
//  PrestagesView.swift
//
//  Created by Amos Deane on 29/01/2024.
//

import SwiftUI

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
]


//    #################################################################################
//      All Prestages
//    #################################################################################


struct PrestagesView: View {
    
    @EnvironmentObject var prestageController: PrestageBrain

    @State private var searchText = ""
    
    @State var server: String

    @State var showAssignedDevices: Bool = false
    
    @State var allPrestages: [PreStage]
    
    @State var selectedPrestage: PreStage = PreStage(keepExistingSiteMembership: (0 != 0), enrollmentSiteId: "", id: "", displayName: "")
    
    @available(macOS 13.0, *)
    
    var body: some View {

        VStack(alignment: .leading) {
            
            if prestageController.allPsComplete == true && prestageController.allPrestages.count > 0 {
                
                NavigationView {
                    
                    VStack(alignment: .leading) {
#if os(macOS)
                        List(searchResults, id: \.self, selection: $selectedPrestage) { prestage in
                            NavigationLink(destination: PrestagesDetailView(prestage: prestage)) {
                                HStack() {
                                    HStack {
                                        Image(systemName: "smallcircle.filled.circle")
                                        Text("\(prestage.displayName) ID:\(prestage.id)")
                                    }
                                }
                                .padding(.horizontal)
                                .foregroundColor(.blue)
                                .frame(minWidth: 450,alignment: .leading)
                                #if os(macOS)
                .navigationTitle("List all Prestages")
#endif
                            }
                        }
                        .frame(minWidth: 400, minHeight: 100, alignment: .leading)
                        .searchable(text: $searchText)
#else

                        List(searchResults, id: \.self) { prestage in
                            NavigationLink(destination: PrestagesDetailView(prestage: prestage)) {
                                HStack() {
                                    HStack {
                                        Image(systemName: "smallcircle.filled.circle")
                                        Text("\(prestage.displayName) ID:\(prestage.id)")
                                    }
                                }
                                .padding(.horizontal)
                                .foregroundColor(.blue)
                                .navigationTitle("List all Prestages")
                            }
                        }
                        .frame(minWidth: 400, minHeight: 100, alignment: .leading)
                        .searchable(text: $searchText)
#endif
   
                    }
                    
                    
                    if showAssignedDevices == true {
                        
                        if let prestageMembers = prestageController.selectedPrestageScope {
                            
                            if prestageMembers == prestageController.selectedPrestageScope {
                                
                                NavigationView {
                                    
                                    List {
                                        ForEach(prestageMembers.assignments, id: \.self) { prestageAssignment in
                                            NavigationLink(destination: PrestageDetailView2(prestageAssignment: prestageAssignment)) {
                                                HStack {
                                                    Image(systemName: "desktopcomputer")
                                                    Text(prestageAssignment.serialNumber)
                                                }
                                            }
                                        }
                                    }
                                    .foregroundColor(.blue)
                                    .frame(minWidth: 400, minHeight: 100, alignment: .leading)
                                    .padding()
                                }
                                
                            } else {
                                ProgressView {
                                    Text("Loading")
                                        .font(.title)
                                }
//                                .padding()
                            }
                        }
                    }
                }
                
            } else {
                
                if prestageController.allPsComplete == false {
                    
                    ProgressView {
                        Text("Loading")
                            .font(.title)
                            .padding()
                    }
                    
                } else {
                    
                    Text("No Prestages Found")
                        .padding()
                }
            }
        }
#if os(iOS)
        .padding()
#endif
        .onAppear {
            
            print("Hide prestage memebers")
            showAssignedDevices = false
            showPrestage(prestageID: selectedPrestage.id)
            
            Task {
                
                print("Running: getAllDevicesPrestageScope")
                
                try await prestageController.getAllDevicesPrestageScope(server: server, prestageID: selectedPrestage.id, authToken: prestageController.authToken)
                
                print("Running: getAllPrestages")
                
                try await prestageController.getAllPrestages(server: server, authToken: prestageController.authToken)
                
                showPrestage(prestageID: selectedPrestage.id)
            }
        }
    }
    
    
    func showPrestage(prestageID: String) {
        
        prestageController.separationLine()
        print("Running: showPrestage")
        
        Task {
            try await prestageController.getPrestageCurrentScope(jamfURL: prestageController.server, prestageID: prestageID, authToken: prestageController.authToken)
        }
    }
    
    
    var searchResults: [PreStage] {
        if searchText.isEmpty {
            return prestageController.allPrestages
        } else {
            return prestageController.allPrestages.filter { $0.displayName.contains(searchText) }
        }
    }
}




