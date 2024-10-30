//
//  PrestageBrain.swift
//  StagingArea
//
//  Created by Amos Deane on 26/01/2024.
//

import Foundation
import SwiftUI
    
@MainActor class PrestageBrain: ObservableObject {

    enum NetError: Error {
        case couldntEncodeNamePass
        case badResponseCode
    }
    
    struct JamfProAuth: Decodable {
        let token: String
        let expires: String
    }
    
    @Published var searchText = ""
    @Published var status: Status = .none

    @AppStorage("needsLogin") var needsLogin = true
    @AppStorage("server") var server = ""
    @AppStorage("username") var username = ""
    @AppStorage("password") var password = ""
    @AppStorage("serial") var serial = ""
    
// #########################################################################
//  Build identifiers
// #########################################################################

    
    let product_name = Bundle.main.infoDictionary!["CFBundleName"] as? String
    let product_version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    let build_version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    // #########################################################################
    // The basic container for all prestages
    // #########################################################################

    @Published var prestages: [PreStagesResponse] = []
    // #########################################################################
    // The property to contain all prestage responses
    @Published var allPrestages: [PreStage] = []
    // #########################################################################
    // The property to contain all enrolled devices for a specific prestage - by ID
    @Published var serialPrestageAssignment: [String: String] = [:]
    // #########################################################################
    // The property to contain all prestages by scope - eg. each device, and which prestage it is scoped to
    @Published var allPrestagesScope: DevicesAssignedToAPrestage?
    // #########################################################################
    // The current scope for the selected prestage
    @Published var selectedPrestageScope: ComputerPrestageCurrentScope? = nil
    // #########################################################################
    //  Variables to hold the status response codes of the requests
    
//    #########################################################################
//    Tokens etc
//    #########################################################################

    @Published var authToken = ""
    @Published var tokenComplete: Bool = false
    @Published var tokenStatusCode: Int = 0
    @Published var allPsStatusCode: Int = 0
    @Published var allPsScStatusCode: Int = 0
    @Published var allPsComplete: Bool = false
    @Published var allPsScComplete: Bool = false
    
//  #########################################################################
//  Computer records
//  #########################################################################

    @Published var allComputersBasic: ComputerBasic = ComputerBasic(computers: [])
    @Published var allComputersBasicDict = [ComputerBasicRecord]()
    
//  #########################################################################
//  The version lock for changes to prestages
//  #########################################################################
    var depVersionLock = 0

    enum Status {
        case none
        case fetching
        case badServer
        case badResponse(URLResponse?, Error?)
        case corruptData(Error)
    }
    
//    #########################################################################
    
    func updateStatus(_ status: Status) {
        DispatchQueue.main.async {
            withAnimation {
                self.processStatus(status)
            }
        }
    }
    
    func processStatus(_ status: Status) {
        assert(Thread.isMainThread)

        switch status {
            case .badServer, .badResponse:
                needsLogin = true
                
            default:
                break
        }
        self.status = status
    }
    
    func separationLine() {
        print("-----------------------------------")
    }
    func doubleSeparationLine() {
        print("===================================")
    }
    func asteriskSeparationLine() {
        print("***********************************")
    }
    func atSeparationLine() {
        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    }
    
//  #######################################################################################
//  LIST ALL PRESTAGES
//  #######################################################################################
//  This just lists all prestages. For: PreStagesView
//  #########################################################################

    func getAllPrestages(server: String, authToken: String) async throws {

        self.allPsComplete = false
        print("Setting allPsComplete to:\(self.allPsComplete)")
        let jamfURLQuery = server + "/api/v2/computer-prestages?page=0&page-size=100&sort=id%3Adesc"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
          request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        print("User-Agent is: \(String(describing: product_name))/\(String(describing: build_version))")

        separationLine()
        print("User-Agent is: \(String(describing: product_name))/\(String(describing: build_version))")

        separationLine()
        print("Running func: getAllPrestages")
        
        let (data, response) = try await URLSession.shared.data(for: request)
//        print("getAllPrestages - Json data is:")
//        print(String(data: data, encoding: .utf8) ?? "no data")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
        
        let decoder = JSONDecoder()
        
        if let decodedPrestages = try? decoder.decode(PreStagesResponse.self, from: data) {
            self.allPrestages = decodedPrestages.results
            self.allPsComplete = true
        }
    }
    
//  #######################################################################################
//  GET ALL DEVICES' PRESTAGE SCOPE - For: PrestageScopeView
//  #######################################################################################
//  Function to show which prestage each individual device is assigned to - using serial number and id of prestage
    
    func getAllDevicesPrestageScope(server: String, prestageID: String, authToken: String) async throws {

        self.allPsScComplete = false

        let jamfURLQuery = server + "/api/v2/computer-prestages/scope"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))")

        separationLine()
        print("User-Agent is: \(product_name)/\(build_version)")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        separationLine()
        print("Running func: getAllDevicesPrestageScope")

        let (data, response) = try await URLSession.shared.data(for: request)
        
//        print("getAllDevicesPrestageScope - Json data is:")
//         print(String(data: data, encoding: .utf8) ?? "no data")
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
        
        let decoder = JSONDecoder()
        
        if let decodedPrestages = try? decoder.decode(DevicesAssignedToAPrestage.self, from: data) {

            self.serialPrestageAssignment = decodedPrestages.serialsByPrestageID
            self.allPsScComplete = true
        }
    }
    
//  #######################################################################################
//  GET DEVICES ASSIGNED TO SPECIFIC PRESTAGE
//  #######################################################################################
//  Function to get the devices assigned to the specitfied computer pre-stage, which is specified by id
    
    func getPrestageCurrentScope(jamfURL: String, prestageID: String, authToken: String) async throws {
        
        let jamfURLQuery = jamfURL + "/api/v2/computer-prestages/" + prestageID + "/scope"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))")

        separationLine()
        print("User-Agent is: \(product_name)/\(build_version)")
        separationLine()
        print("Running:getPrestageCurrentScope for prestage id:\(prestageID)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
//        print("getPrestageCurrentScope - Json data is:")
//        print(String(data: data, encoding: .utf8) ?? "no data")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
        
        let decoder = JSONDecoder()
        
        if let decodedPrestages = try? decoder.decode(ComputerPrestageCurrentScope.self, from: data) {
    
            self.depVersionLock = decodedPrestages.versionLock
            self.selectedPrestageScope = decodedPrestages
            
        }
    }

//  #######################################################################################
//  GET DEVICES ASSIGNED TO SPECIFIC PRESTAGE TO ADD DEVICE TO PRESTAGE
//  #######################################################################################
//  Function to get the devices assigned to the specitfied computer pre-stage in preparation for adding
//  This sets the property selectedPrestageScope to contain these pre-stages
    
    func getPrestageCurrentScopeToAdd(jamfURL: String, prestageID: String, authToken: String) async throws {
        
        let jamfURLQuery = jamfURL + "/api/v2/computer-prestages/" + prestageID + "/scope"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))")

        
        separationLine()
        print("Running:getPrestageCurrentScopeToAdd for prestage id:\(prestageID)")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
        
        let decoder = JSONDecoder()
        
        if let decodedPrestages = try? decoder.decode(ComputerPrestageCurrentScope.self, from: data) {
            self.depVersionLock = decodedPrestages.versionLock
            self.selectedPrestageScope = decodedPrestages
            self.depVersionLock = decodedPrestages.versionLock
            print("depVersionLock is now set to:\(self.depVersionLock)")
            self.selectedPrestageScope = decodedPrestages
        }
    }
    
//  #######################################################################################
//  ADD DEVICE TO PRESTAGE
//  #######################################################################################
    
    func addDeviceToPrestage(server: String, prestageID: String, serial: String, authToken: String, depVersionLock: Int) async throws {
        let jamfURLQuery = server + "/api/v2/computer-prestages/" + prestageID + "/scope"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        print("User-Agent is: \(String(describing: product_name))/\(String(describing: build_version))")

        separationLine()
        print("User-Agent is: \(String(describing: product_name))/\(String(describing: build_version))")

        let json: [String: Any] = ["serialNumbers": [serial],
                                   "versionLock": depVersionLock]
        separationLine()
        print("Adding device to prestage:\(serial)")
        print("versionLock is:\(depVersionLock)")
        print("json is:\(json)")
        print("prestageID is:\(prestageID)")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        if let jsonData = jsonData {
            
            request.httpBody = jsonData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
    }
    
//  #######################################################################################
//  REMOVE DEVICE FROM PRESTAGE
//  #######################################################################################
//  Function to remove the computer from a specified computer pre-stage
    
    func removeDeviceFromPrestage(server: String, removeComputerPrestageID: String, serial: String, authToken: String, depVersionLock: Int) async throws {
        
        let jamfURLQuery = server + "/api/v2/computer-prestages/" + removeComputerPrestageID + "/scope/delete-multiple"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name))/\(String(describing: build_version))")

        let json: [String: Any] = ["serialNumbers": [serial],
                                   "versionLock": depVersionLock]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        if let jsonData = jsonData {
            request.httpBody = jsonData
        }
        separationLine()
        print("Removing device:\(serial)")
        print("Removing from prestageID:\(removeComputerPrestageID)")
        print("versionLock is:\(depVersionLock)")
        print("json is:\(json)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }
    }
    
    
    //    #################################################################################
    //    Tokens and Authorisation
    //    #################################################################################
    
    func getToken(server: String, username: String, password: String) async throws {
        print("Getting token - Netbrain")
        
        guard let base64 = encodeBase64(username: username, password: password) else {
            print("Error encoding username/password")
            throw NetError.couldntEncodeNamePass
        }
        
        let tokenURLString = server + "/api/v1/auth/token"
        let url = URL(string: tokenURLString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))")

        let (data, response) = try await URLSession.shared.data(for: request)
        self.tokenStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200")
            throw NetError.badResponseCode
        }
        
        let auth = try JSONDecoder().decode(JamfProAuth.self, from: data)
        print("We have a token")
//        print("Connected to:\(server)")
//        print("Username is:\(username)")
        self.authToken = auth.token
    }
    
    // This function generates the base64 from a username name and password
    func encodeBase64(username: String, password: String) -> String? {
        let authString = username + ":" + password
        let encoded = authString.data(using: .utf8)?.base64EncodedString()
        return encoded
    }
    
    func getComputersBasic(server: String, authToken: String) async throws {
        
        print("Running getComputersBasic")
        let jamfURLQuery = server + "/JSSResource/computers/subset/basic"
        let url = URL(string: jamfURLQuery)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))", forHTTPHeaderField: "User-Agent")
        separationLine()
        print("User-Agent is: \(String(describing: product_name ?? ""))/\(String(describing: build_version ?? ""))")


        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("getComputersBasic - Json data is:")
         print(String(data: data, encoding: .utf8) ?? "no data")

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("Code not 200 - response is:\(response)")
            throw NetError.badResponseCode
        }

        let decoder = JSONDecoder()
        
        self.allComputersBasic = try decoder.decode(ComputerBasic.self, from: data)
        self.allComputersBasicDict = self.allComputersBasic.computers
    }
}


