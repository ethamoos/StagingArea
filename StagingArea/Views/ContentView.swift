

import SwiftUI
import Foundation

#if canImport(FoundationNetworking)
//import FoundationNetworking
#endif
//import Cocoa


struct ContentView: View {
    
    @EnvironmentObject var prestageController: PrestageBrain

        @AppStorage("server") var server = ""
        @AppStorage("user") var username = ""
        @AppStorage("password") var password = ""
    
    @State var showLoginScreen = true
    
    var body: some View {
        
        if showLoginScreen {
            LoginView(showLoginScreen: $showLoginScreen)
        } else {
            OptionsView(showLoginScreen: $showLoginScreen, server: server, username: username, password: password)
        }
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

