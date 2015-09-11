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

protocol SaveContactToAddressBookDelegate {
    func savingSuccessfull()
    func savingFailed()
    func nothingToSave()
    func noAccessGranted()
}
class SaveContactToAddressBook {
    
    var addressBookRef: ABAddressBook!
    var contactToSave: ParticipantsInformation?
    var delegate: SaveContactToAddressBookDelegate?
    
    func saveSelectedContact(contact: ParticipantsInformation) {
        contactToSave = contact
        getAuthorizationForAddressBook()
    }
    
    private func getAuthorizationForAddressBook() {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        
        switch authorizationStatus {
        case .Denied, .Restricted:
            if let delegate = self.delegate {
                delegate.noAccessGranted()
            }
        case .Authorized:
            addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            addContact()
        case .NotDetermined:
            promptForAddressBookRequestAccess()
        }
    }
    
    private func promptForAddressBookRequestAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {

                } else {
                    self.addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
                    self.addContact()
                }
            }
        }
    }
    
    private func addContact() {
        makeAndAddContactRecord()
    }
    
    private func getContactRecord() -> ABRecordRef? {
        let allContacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as Array
        var contact: ABRecordRef?
        for record in allContacts {
            let currentContact: ABRecordRef = record
            let currentContactName = ABRecordCopyCompositeName(currentContact).takeRetainedValue() as String
            if let contactName = contactToSave?.fullName {
                if (currentContactName == contactName) {
                    contact = currentContact
                }
            }
        }
        return contact
    }
    
    private func makeAndAddContactRecord() -> ABRecordRef {
        let contactRecord: ABRecordRef = ABPersonCreate().takeRetainedValue()
        
        ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, contactToSave?.fullName, nil)
        ABRecordSetValue(contactRecord, kABPersonOrganizationProperty, contactToSave?.company, nil)
        let phoneNumbers: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
        ABMultiValueAddValueAndLabel(phoneNumbers, contactToSave?.phoneNumber, kABPersonPhoneMainLabel, nil)
        ABRecordSetValue(contactRecord, kABPersonPhoneProperty, phoneNumbers, nil)
        
        ABAddressBookAddRecord(addressBookRef, contactRecord, nil)
        saveAddressBookChanges()
        
        return contactRecord
    }
    
    private func saveAddressBookChanges() {
        if ABAddressBookHasUnsavedChanges(addressBookRef){
            var err: Unmanaged<CFErrorRef>? = nil
            let savedToAddressBook = ABAddressBookSave(addressBookRef, &err)
            if savedToAddressBook {
                if let delegate = self.delegate {
                    delegate.savingSuccessfull()
                }
            } else {
                if let delegate = self.delegate {
                    delegate.savingFailed()
                }
            }
        } else {
            if let delegate = self.delegate {
                delegate.nothingToSave()
            }
        }
    }
}