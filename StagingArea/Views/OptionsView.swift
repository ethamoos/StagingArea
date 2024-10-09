import SwiftUI

struct OptionsView: View {
    
    @EnvironmentObject var prestageController: PrestageBrain
    
    @Binding var showLoginScreen: Bool

    
    //  #######################################################################
    //  PRESTAGE STUFF
    //  #######################################################################
    
    @State var prestageID = ""
    @State var serial = ""
    
    var server: String
    var username: String
    var password: String
    
    //  #######################################################################
    //  PRESTAGE STUFF
    //  #######################################################################
    
    
    var body: some View {
        
        VStack(spacing: 50) {
            
            if prestageController.tokenStatusCode == 200 {
                    
                    NavigationView {
                        
                        List {
                            
                            NavigationLink(destination: PrestagesView( server: server, allPrestages: prestageController.allPrestages)) {
                                Text("All Prestages")
                            }
                            
                            NavigationLink(destination: PrestagesAssignedView(server: server)) {
                                Text("All Devices Assigned")
                            }
                            
                            NavigationLink(destination: PrestagesEditView(server: server, showProgressScreen: false, initialPrestageID: "", targetPrestageID: "", serial: "")) {
                                Text("Edit Device Assignment")
                            }
                            
                            NavigationLink(destination: PrestageAddDeviceView( targetPrestageID: "", serial: "")) {
                                Text("Add Unassigned Device")
                            }
                            
                        }
                        .frame(minWidth: 100)
                        .listStyle(.sidebar)
                        .padding(30)
                        .toolbar(id: "Main") {
      
                            ToolbarItem(id: "Connect") {
                                Button(action: {
                                    showLoginScreen = true
                                }) {
                                    HStack {
                                        Text("Connect")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        .frame(minWidth: 220)
                        .foregroundColor(.blue)
                    }
                
            } else {
                
                if prestageController.tokenComplete == false {
                    ProgressView {
                        Text("Loading")
                            .font(.title)
                            .padding()
                    }
                    
                } else {
                    
                    Text("Login Error Encountered - Please Check Your Credentials")
                    
                    Button(action: {
                        
                        showLoginScreen = true                        }) {
                            
                        HStack(spacing:30) {
                            Text("Return to Login").foregroundColor(Color.black).bold()
                        }
                    }
                }
            }
        }
       
        
        .onAppear {
            
            print("OptionsView appeared - connecting")
            
            Task {
               
            try await prestageController.getToken(server: server, username: username, password: password)
                
            }
        }
    }
}

//struct OptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        OptionsView()
//    }
//}
