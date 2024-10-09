

import Foundation


// MARK: - PreStages
// The basic structure for prestages
struct PreStagesResponse: Codable {
    let totalCount: Int
    let results: [PreStage]
}

// MARK: - Result
struct PreStage: Codable, Identifiable, Hashable, Comparable {
    
    static func < (lhs: PreStage, rhs: PreStage) -> Bool {
        lhs.displayName < rhs.displayName
        
    }
    
    let keepExistingSiteMembership: Bool
    let enrollmentSiteId, id, displayName: String
    //    let supportPhoneNumber: SupportPhoneNumber
    //    let supportEmailAddress: SupportEmailAddress
    //    let department: Department
    //    let mandatory, mdmRemovable, defaultPrestage, keepExistingLocationInformation: Bool
    //    let requireAuthentication: Bool
    //    let authenticationPrompt, profileUUID, deviceEnrollmentProgramInstanceID: String
    //    let versionLock: Int
    //    let siteID: String
    //    let skipSetupItems: [String: Bool]
    //    let locationInformation: LocationInformation
    //    let purchasingInformation: PurchasingInformation
    //    let preventActivationLock, enableDeviceBasedActivationLock: Bool
    //    let anchorCertificates: [JSONAny]
    //    let enrollmentCustomizationID: String
    //    let language: Language
    //    let region: Region
    //    let autoAdvanceSetup: Bool
    //    let customPackageIDS: [JSONAny]
    //    let customPackageDistributionPointID: String
    //    let installProfilesDuringSetup: Bool
    //    let prestageInstalledProfileIDS: [String]
    //    let enableRecoveryLock: Bool
    //    let recoveryLockPasswordType: RecoveryLockPasswordType
    //    let rotateRecoveryLockPassword: Bool
    
    //    enum CodingKeys: String, CodingKey {
    //        case keepExistingSiteMembership
    //        case enrollmentSiteID = "enrollmentSiteId"
    //        case id, displayName, supportPhoneNumber, supportEmailAddress, department, mandatory, mdmRemovable, defaultPrestage, keepExistingLocationInformation, requireAuthentication, authenticationPrompt
    //        case profileUUID = "profileUuid"
    //        case deviceEnrollmentProgramInstanceID = "deviceEnrollmentProgramInstanceId"
    //        case versionLock
    //        case siteID = "siteId"
    //        case skipSetupItems, locationInformation, purchasingInformation, preventActivationLock, enableDeviceBasedActivationLock, anchorCertificates
    //        case enrollmentCustomizationID = "enrollmentCustomizationId"
    //        case language, region, autoAdvanceSetup
    //        case customPackageIDS = "customPackageIds"
    //        case customPackageDistributionPointID = "customPackageDistributionPointId"
    //        case installProfilesDuringSetup
    //        case prestageInstalledProfileIDS = "prestageInstalledProfileIds"
    //        case enableRecoveryLock, recoveryLockPasswordType, rotateRecoveryLockPassword
    //    }
}





//Struct to hold the returned details for a specific computer prestage
struct ComputerPrestageCurrentScope: Codable, Equatable {
    let prestageId: String
    let assignments: [ComputerPreStageScopeAssignment]
    let versionLock: Int
}

//Struct to hold the details of a specific prestage - including the devices assigned and their assignment date
struct ComputerPreStageScopeAssignment: Codable, Hashable {
    let serialNumber: String
    let assignmentDate: String // assignmentDate and String
    let userAssigned: String
}

// Structure to hold the details for all devices assigned to a prestage
struct DevicesAssignedToAPrestage: Codable {
    let serialsByPrestageID: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case serialsByPrestageID = "serialsByPrestageId"
    }
}

// MARK: - ComputerBasic
struct ComputerBasic: Codable {
    let computers: [ComputerBasicRecord]
}

// MARK: - Computer
struct ComputerBasicRecord: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let managed: Bool
    let username, model, department, building: String
    let macAddress, udid, serialNumber, reportDateUTC: String
    let reportDateEpoch: Int

    enum CodingKeys: String, CodingKey {
        case id, name, managed, username, model, department, building
        case macAddress = "mac_address"
        case udid
        case serialNumber = "serial_number"
        case reportDateUTC = "report_date_utc"
        case reportDateEpoch = "report_date_epoch"
    }
}
