// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

/// Implemented by `RegisterApplication`; use this for delegates
/// or view controller callbacks.
public protocol HandlesRegistering: class {

    func register(name: String, licenseCode: String)
}

class RegisterApplication: HandlesRegistering {

    let licenseVerifier: LicenseVerifier
    let licenseWriter: LicenseWriter
    let changeBroadcaster: LicenseChangeBroadcaster

    typealias InvalidLicenseCallback = (_ name: String, _ licenseCode: String) -> Void
    let invalidLicenseCallback: InvalidLicenseCallback

    init(licenseVerifier: LicenseVerifier,
         licenseWriter: LicenseWriter,
         changeBroadcaster: LicenseChangeBroadcaster,
         invalidLicenseCallback: @escaping InvalidLicenseCallback) {

        self.licenseVerifier = licenseVerifier
        self.licenseWriter = licenseWriter
        self.changeBroadcaster = changeBroadcaster
        self.invalidLicenseCallback = invalidLicenseCallback
    }

    func register(name: String, licenseCode: String) {

        guard licenseVerifier.isValid(licenseCode: licenseCode, forName: name) else {

            invalidLicenseCallback(name, licenseCode)
            return
        }

        let license = License(name: name, licenseCode: licenseCode)
        let licenseInformation = LicenseInformation.registered(license)

        licenseWriter.store(license: license)
        changeBroadcaster.broadcast(licenseInformation)
    }
}