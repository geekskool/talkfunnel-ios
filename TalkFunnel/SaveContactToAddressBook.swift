//
//  SaveContactToAddressBook.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 02/09/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

class SaveContactToAddressBook {
    
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    
    func promptForAddressBookRequestAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    //denied
                } else {
                    self.addContact()
                }
            }
        }
    }
    
    func addContact() {
        makeAndAddContactRecord()
    }
    
    func getContactRecord() -> ABRecordRef? {
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
        var contact: ABRecordRef?
        for record in allContacts {
            let currentContact: ABRecordRef = record
            let currentContactName = ABRecordCopyCompositeName(currentContact).takeRetainedValue() as String
            if let contactName = scannedParticipantInfo?.fullName {
                if (currentContactName == contactName) {
                    print("found \(contactName).")
                    contact = currentContact
                }
            }
        }
        return contact
    }
    
    func makeAndAddContactRecord() -> ABRecordRef {
        let contactRecord: ABRecordRef = ABPersonCreate().takeRetainedValue()
        
        ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, scannedParticipantInfo?.fullName, nil)
        ABRecordSetValue(contactRecord, kABPersonOrganizationProperty, scannedParticipantInfo?.company, nil)
        let phoneNumbers: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(phoneNumbers, scannedParticipantInfo?.phoneNumber, kABPersonPhoneMainLabel, nil)
        ABRecordSetValue(contactRecord, kABPersonPhoneProperty, phoneNumbers, nil)
        
        ABAddressBookAddRecord(addressBookRef, contactRecord, nil)
        saveAddressBookChanges()
        
        return contactRecord
    }
    
    func saveAddressBookChanges() {
        if ABAddressBookHasUnsavedChanges(addressBookRef){
            var err: Unmanaged<CFErrorRef>? = nil
            let savedToAddressBook = ABAddressBookSave(addressBookRef, &err)
            if savedToAddressBook {
                print("Successully saved changes.")
            } else {
                print("Couldn't save changes.")
            }
        } else {
            print("No changes occurred.")
        }
    }
    
    func getAuthorizationForAddressBook() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .Denied, .Restricted:
            print("denied")
        case .Authorized:
            print("authorized")
            addContact()
        case .NotDetermined:
            print("donno")
            promptForAddressBookRequestAccess()
        }
    }
}