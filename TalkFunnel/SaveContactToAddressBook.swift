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
    
    func createGroup(groupName: String) -> ABRecordRef {
        let groupRecord: ABRecordRef = ABGroupCreate().takeRetainedValue()
        let allGroups = ABAddressBookCopyArrayOfAllGroups(addressBookRef).takeRetainedValue() as Array
        for group in allGroups {
            let currentGroup: ABRecordRef = group
            let currentGroupName = ABRecordCopyValue(currentGroup, kABGroupNameProperty).takeRetainedValue() as! String
            if (currentGroupName == groupName) {
                print("Group exists")
                return currentGroup
            }
        }
        ABRecordSetValue(groupRecord, kABGroupNameProperty, groupName, nil)
        ABAddressBookAddRecord(addressBookRef, groupRecord, nil)
        saveAddressBookChanges()
        print("Made group")
        return groupRecord
    }
    
    func addContactToGroup(contact:ABRecordRef) {
        let groupName = "HasGeek Event"
        let group: ABRecordRef = createGroup(groupName)
        // 1. Check if the member is already a part of the group.
        // 1a. Check if there are any members.
        if let groupMembersArray = ABGroupCopyArrayOfAllMembers(group) {
            let groupMembers = groupMembersArray.takeRetainedValue() as Array
            // 1b. Check if any of the members match the current contact.
            for member in groupMembers {
                let currentMember: ABRecordRef = member
                if currentMember === contact {
                    print("Already in it.")
                    return
                }
            }
        }
        
        // 2. Add the member to the group
        let addedToGroup = ABGroupAddMember(group, contact, nil)
        if !addedToGroup {
            print("Couldn't add pet to group.")
        }
        
        // 3. Save the changes
        saveAddressBookChanges()
    }
    
    func addContact() {
        
//        if let _: ABRecordRef = getContactRecord() {
//            print("contact Exists")
//            return
//        }
        
        let contactRecord: ABRecordRef = makeAndAddContactRecord()
        print("contact added")
        self.addContactToGroup(contactRecord)
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
//        ABRecordSetValue(contactRecord, kABPersonEmailProperty, scannedParticipantInfo?.email, nil)
//        ABRecordSetValue(contactRecord, kABPersonOrganizationProperty, scannedParticipantInfo?.company, nil)
//        ABRecordSetValue(contactRecord, kABPersonEmailProperty, scannedParticipantInfo?.fullName, nil)
        
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