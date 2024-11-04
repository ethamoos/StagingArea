//
//  PrestageAddDeviceView.swift
//  StagingArea
//
//  Created by Amos Deane on 21/06/2022.
//

import SwiftUI


//    #################################################################################
//      PrestageAddDeviceView
//    #################################################################################

struct PrestageAddDeviceView: View {
    
    //      Allows the user to add a device not assigned to a prestage
    
    @EnvironmentObject var prestageController: PrestageBrain
    
    @State var targetPrestageID: String
    
    @State var serial: String
        
    @State var selectedPrestageTarget: PreStage = PreStage(keepExistingSiteMembership: (0 != 0), enrollmentSiteId: "", id: "", displayName: "")
    
    let columns = [
        GridItem(.fixed(300)),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            LazyVGrid(columns: columns, spacing: 20) {
                
                HStack {
                    Label("serial", systemImage: "globe")
                    TextField("serial", text: $serial)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 20) {
                Picker(selection: $selectedPrestageTarget, label: Text("Target Prestage:").bold()) {
                    Text("").tag("") //basically added empty tag and it solve the case
                    ForEach(prestageController.allPrestages.sorted(), id: \.self) { prestage in
                        Text(String(describing: prestage.displayName)).tag("")
                    }
                }
            }
            
            Button(action: {
                showPrestage(targetPrestageID: $selectedPrestageTarget.id)
            }) {
                HStack(spacing:10) {
                    Text("Update")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Spacer()
                .padding(.all)
                .navigationTitle("Add Unassigned Device")
        }
        .padding(.all)

#if os(iOS)
        .padding(20)
        .border(Color.blue)
        .offset(y: 15)
#endif
    }
    
    
    func showPrestage(targetPrestageID: String) {
        prestageController.separationLine()
        print("Running: showPrestage")
        Task {
            try await prestageController.addDeviceToPrestage(server: prestageController.server, prestageID: targetPrestageID, serial: serial, authToken: prestageController.authToken, depVersionLock: prestageController.depVersionLock)
        }
    }
}



//}
//struct PrestageEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrestageEditView()
//    }
//}
