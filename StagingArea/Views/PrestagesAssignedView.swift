//
//  PrestagesAssignedView.swift
//  Manifesto
//
//  Created by Amos Deane on 29/01/2024.
//


import SwiftUI

struct PrestagesAssignedView: View {
    
    //    #################################################################################
    //      All Devices Assigned
    //    #################################################################################
    //    This lists all devices that are assigned to a prestage
    
    @EnvironmentObject var prestageController: PrestageBrain
    
    @State var searchText = ""
    
    @State var server: String
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            
            if prestageController.allPsScComplete == true && prestageController.serialPrestageAssignment.count > 0 {
                
                NavigationView {
                    
                    List (searchResults, id: \.self) { serial in
                        NavigationLink(destination: PrestagesEditView(server: server, showProgressScreen: false, initialPrestageID: prestageController.serialPrestageAssignment[serial] ?? "", targetPrestageID: "", serial: serial)) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                Text (serial)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
//                    List (prestageController.allComputersBasicDict, id: \.self) { computer in
//                        //                        NavigationLink(destination: PrestagesEditView(server: server, showProgressScreen: false, initialPrestageID: prestageController.serialPrestageAssignment[serial] ?? "", targetPrestageID: "", serial: serial)) {
//                        HStack {
//                            Image(systemName: "desktopcomputer")
//                            Text ("\(computer.name), \(computer.serialNumber)")
//                        }
//                    .foregroundColor(.blue)
//                    }
                    
                    .searchable(text: $searchText)
#if os(macOS)
                    .navigationTitle("Devices by Prestage ID")
#endif
                    .frame(minWidth: 400, minHeight: 100, alignment: .leading)
                    
                    Text("\(prestageController.serialPrestageAssignment.count) Devices found")
                    
                }
                
            } else {
                
                if prestageController.allPsScComplete == false {
                    
                    ProgressView {
                        
                        Text("Loading")
                        //                            .progressViewStyle(.horizontal)
                    }
                } else {
                    Text("No Devices Assigned To A Prestage")
                        .padding()
                }
            }
        }
#if os(iOS)
        .padding()
//        .navigationBarBackButtonHidden(true)
#endif
        
        .onAppear {
            
            Task {
                try await prestageController.getAllDevicesPrestageScope(server: server, prestageID: prestageController.serialPrestageAssignment[""] ?? "" , authToken: prestageController.authToken)
                
                try await prestageController.getComputersBasic(server: server, authToken: prestageController.authToken)
            }
        }
    }
        
        var searchResults: [String] {
            
            let serialsArray = Array (prestageController.serialPrestageAssignment.keys)
            
            if searchText.isEmpty {
                return serialsArray
            } else {
                return serialsArray.filter { $0.contains(searchText) }
            }
        }
    }
    
    
    
    //struct PrestagesAssignments_Previews: PreviewProvider {
    //    static var previews: some View {
    //        PrestagesAssignments(server: server)
    //    }
    //}
