
import SwiftUI

struct LoginView: View {
    
    @Binding var showLoginScreen: Bool
    
    @State var currentToken = ""
    
    @AppStorage("server") var server = ""
    @AppStorage("user") var username = ""
    @AppStorage("password") var password = ""
    @EnvironmentObject var prestageController: PrestageBrain
        
    var body: some View {
        
#if os(iOS)
        
        let columns = [
            GridItem(.fixed(60)),
            GridItem(.fixed(170))
        ]
        
#else
        
        let columns = [
            GridItem(.fixed(170)),
            GridItem(.fixed(200))
        ]
        
#endif

        
        VStack {
            
            VStack(alignment: .leading, spacing: 20) {
                
                
                VStack {
                        Text(LocalizedStringKey("Welcome"))
                            .font(.title)
                    }
                    .padding()
                
                

                LazyVGrid(columns: columns, spacing: 20) {

                
                    HStack {
                        Spacer()
#if os(macOS)

                        Label("server", systemImage: "globe")
                        #else
                        Text("server")

#endif
                    }
                    
                    TextField("server", text: $server)
                        .disableAutocorrection(true)
#if os(iOS)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
#endif
                        .padding()
                    
                    HStack {
                        Spacer()
#if os(macOS)

                        Label("user", systemImage: "person")
#else

                        Text("user")
#endif

                        
                        
                    }
                    
                    TextField("username", text: $username)
                        .disableAutocorrection(true)
#if os(iOS)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
#endif
                        .padding()
                    
                    HStack {
                        Spacer()
                        
#if os(macOS)

                        Label("password", systemImage: "ellipsis.rectangle")
#else

                        Text("pword")
                        
#endif

                        
                        
                    }
                    
                    SecureField("password", text: $password)
                        .disableAutocorrection(true)
#if os(iOS)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
#endif
                        .padding()
                }
            }
            
            Button(action: {
                
                showLoginScreen = false
                
            }) {
                HStack(spacing:30) {
                    Image(systemName: "tortoise")
                    withAnimation {
                        Text("Proceed")
                    }
                }
            }
            .padding()
        }
#if os(macOS)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

#endif
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView(showLoginScreen: Binding:true)
//    }
//}
