//
//  FetchData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 12/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation
import UIKit
import CoreData


//MARK: Global variables
var eventList = [EventList]()
var currentEvent: EventList?
var currentEventTitle: String?
var currentEventInformation: EventInformation?

var schedule = [[Session]]()

var savedContacts = [ParticipantsInformation]()
var allParticipantsInfo = [ParticipantsInformation]()
var scannedParticipantInfo: ParticipantsInformation?

var scannedContactPublicKey: String?
var scannedContactPrivateKey: String?
var userLogInString: String?
var userAccessToken: String?
var userTokenType: String?
var hasAppRunBefore: Bool?

var isScanComplete = false
var isUserLoggedIn = false {
willSet(newValue) {
    if newValue {
        retrieveUserData()
    }
}
}

//Mark: Constants
private struct constants {
    static let EventListUrl = "https://talkfunnel.com/json"
    static let UserLoginUrl = "http://auth.hasgeek.com/auth?client_id=eDnmYKApSSOCXonBXtyoDQ&scope=id+email+phone+organizations+teams+com.talkfunnel:*&response_type=token"
}

private struct defaultsKeys {
    static let userAccessToken = "Access Token"
    static let userTokenType = "Token Type"
    static let contactPublicKey = "Public Key"
    static let contactPrivateKey = "Private Key"
    static let currentEventTitle = "Current Event Title"
    static let hasAppRunBefore = "Has App Run Before"
}


// Working with dates

func isEventAfterToday(event: EventList) -> Bool {
    let today = NSDate()
    if let eventDate = getDateFromString(event.endDate) {
        if today.compare(eventDate) == .OrderedAscending {
            return true
        }
    }
    else {
        if let eventDate = getDateFromString(event.startDate) {
            if today.compare(eventDate) == .OrderedAscending {
                return true
            }
        }
    }
    return false
    
}

func getCurrentEvent() {
    let today = NSDate()
    var closestEventToToday = getDateFromString(eventList[0].startDate)
    currentEvent = eventList[0]
    for event in eventList {
        if let tempStartDate = getDateFromString(event.startDate) {
            if let tempEndDate = getDateFromString(event.endDate) {
                if today.compare(tempStartDate) == .OrderedDescending && today.compare(tempEndDate) == .OrderedAscending {
                    if closestEventToToday?.compare(tempStartDate) == .OrderedDescending {
                        closestEventToToday = tempStartDate
                        currentEvent = event
                    }
                }
                else {
                    if closestEventToToday?.compare(tempStartDate) == .OrderedDescending {
                        closestEventToToday = tempStartDate
                        currentEvent = event
                    }
                }
            }
                
            else {
                if closestEventToToday?.compare(tempStartDate) == .OrderedDescending {
                    closestEventToToday = tempStartDate
                    currentEvent = event
                }
            }
        }
    }
}

func getCurrentEventFromSavedData() {
    for event in eventList {
        if currentEventTitle == event.title {
            currentEvent = event
        }
    }
}

func getDateFromString(dateString: String?) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" //iso 8601
    if let eventDate = dateString {
        if let date = dateFormatter.dateFromString(eventDate){
            return date
        }
    }
    return nil
}

func getTimeFromString(timeString: String?) -> NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH:mm" //iso 8601
    if let talkTime = timeString {
        if let time = dateFormatter.dateFromString(talkTime){
            return time
        }
    }
    return nil
}


//Working with the Current Event
func getScheduleForCurrentEvent() {
    schedule.removeAll()
    if let scheduleForCurrentEvent = currentEventInformation?.schedule {
        for scheduleForDay in scheduleForCurrentEvent {
            addTalksPerSection(scheduleForDay)
        }
    }
}

func addTalksPerSection(scheduleForDay: Schedule?) {
    var talksPerSection = [Session]()
    if let slots = scheduleForDay?.slots{
        for slot in slots {
            let sessions = slot.sessions
            for session in sessions {
                talksPerSection.append(session)
            }
        }
        schedule.append(talksPerSection)
    }
}


//MARK: Initial Data Fetch
func fetchAllData(callback: (Bool,String?) -> Void) {
    fetchDataForEventList { (doneFetchingEventList, errorFetchingEventList) -> Void in
        if doneFetchingEventList {
            fetchDataForEvent({ (doneFetchingEventInformation, errorFetchingEventInformation) -> Void in
                if doneFetchingEventInformation {
                    callback(true,nil)
                }
                else {
                    callback(false,errorFetchingEventInformation)
                }
            })
        }
        else {
            callback(false,errorFetchingEventList)
        }
    }
}

func fetchParticipantData(callback: Bool -> Void) {
    fetchParticipantRelatedData("participants/json", callback: { (doneFetchingParticipantData,errorFetchingParticipantData) -> Void in
        if doneFetchingParticipantData {
            callback(true)
        }
        else {
            callback(false)
        }
    })
}

func fetchParticipantRelatedData(urlAddition: String, callback: (Bool,String?) -> Void) {
    if isUserLoggedIn {
        if let currentEventURL = currentEvent?.url {
            let participantListURL = currentEventURL + urlAddition
            let participantListRequestValue = "Bearer " + userAccessToken!
            let participantListRequestHeader = "Authorization"
            HttpRequest(url: participantListURL, requestValue: participantListRequestValue, requestHeader: participantListRequestHeader, callback: { (data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error != nil {
                        callback(false,error)
                    }
                    else {
                        if let allParticipants = data["participants"] as? NSArray {
                            allParticipantsInfo.removeAll()
                            for participants in allParticipants {
                                if let dict = participants as? NSDictionary {
                                    let data = ParticipantsInformation(participant: dict)
                                    allParticipantsInfo.append(data)
                                }
                            }
                            saveFetchedParticipantData()
                            callback(true,nil)
                        }
                        else {
                            callback(false,nil)
                        }
                    }
                })
            })
        }
        else {
            callback(false,nil)
        }
    }
    else {
        callback(false,nil)
    }
}

func fetchSavedContactData(url: String, callback: (Bool,String?) -> Void) {
    if isUserLoggedIn {
        let contactRequestValue = "Bearer " + userAccessToken!
        let contactRequestHeader = "Authorization"
        HttpRequest(url: url, requestValue: contactRequestValue, requestHeader: contactRequestHeader, callback: { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if error != nil {
                    print(error)
                    callback(false,error)
                }
                else {
                    if let allParticipants = data["participant"] as? NSDictionary {
                        scannedParticipantInfo = ParticipantsInformation(participant: allParticipants)
                        callback(true,nil)
                    }
                    else {
                        callback(false,nil)
                    }
                }
            })
        })
    }
}

func getSavedContacts() {
    savedContacts.removeAll()
    for participant in allParticipantsInfo {
        if participant.privateKey != "" {
            savedContacts.append(participant)
        }
    }
}

func fetchDataForEvent(callback: (Bool,String?) -> Void) {
    HttpRequest(url: (currentEvent?.jsonUrl)!) {
        (data, error) -> Void in
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if error != nil {
                callback(false,error)
            }
            else {
                currentEventInformation = EventInformation(data: data)
                getScheduleForCurrentEvent()
                saveFetchedEventInformation()
                callback(true,nil)
            }
        }
    }
}

func fetchDataForEventList(callback: (Bool,String?) -> Void) {
    var tempEventList = eventList
    tempEventList.removeAll()
    HttpRequest(url: constants.EventListUrl) {
        (data, error) -> Void in
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if error != nil {
                callback(false,error)
            }
            else {
                if let spaces = data["spaces"] as? NSArray {
                    for events in spaces {
                        if let eventInfo = events as? NSDictionary {
                            let dict = EventList(data: eventInfo)
                            if isEventAfterToday(dict) {
                                tempEventList.append(dict)
                            }
                        }
                    }
                    eventList = tempEventList
                    getCurrentEvent()
                    saveFetchedEventList()
                    sortFetchedEventList()
                    callback(true,nil)
                }
                else {
                    callback(false,nil)
                }
            }
        }
    }
}

//MARK: NSUserDefaults
func getLocalData() {
    let defaults = NSUserDefaults.standardUserDefaults()
    userAccessToken = defaults.valueForKey(defaultsKeys.userAccessToken) as? String
    userTokenType = defaults.valueForKey(defaultsKeys.userTokenType) as? String
    currentEventTitle = defaults.valueForKey(defaultsKeys.currentEventTitle) as? String
    hasAppRunBefore = defaults.valueForKey(defaultsKeys.hasAppRunBefore) as? Bool
    if userAccessToken != nil && userTokenType != nil {
        isUserLoggedIn = true
    }
    getSavedContacts()
}

func addToLocalData() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setValue(userAccessToken, forKey: defaultsKeys.userAccessToken)
    defaults.setValue(userTokenType, forKey: defaultsKeys.userTokenType)
    defaults.setValue(currentEvent?.title, forKey: defaultsKeys.currentEventTitle)
    defaults.setValue(true, forKey: defaultsKeys.hasAppRunBefore)
    defaults.synchronize()
}

func retrieveUserData() {
    if userAccessToken == nil {
        let str = userLogInString?.componentsSeparatedByString("=")
        if let strings = str {
            let strArray1 = strings[1].componentsSeparatedByString("&")
            userAccessToken = strArray1[0]
            let strArray2 = strings[2].componentsSeparatedByString("&")
            userTokenType = strArray2[0]
            if userAccessToken != nil && userTokenType != nil {
                addToLocalData()
            }
        }
    }
}

//MARK: Core data

//MARK: CoreData - Fetch

func fetchAllSavedData(callback: (Bool,String?) -> Void) {
    fetchSavedEventList { (doneFetching,error) -> Void in
        if doneFetching {
            fetchSavedEventInformation({ (doneFetchingEventInfo, errorFetchingEventInfo) -> Void in
                if doneFetchingEventInfo {
                    fetchSavedParticipantData({ (doneFetchingParticipantData, errorFetchingParticipantData) -> Void in
                        if doneFetchingParticipantData {
                            callback(true,nil)
                        }
                        else {
                            callback(false,errorFetchingParticipantData)
                        }
                    })
                }
                else {
                    callback(false,errorFetchingEventInfo)
                }
            })
        }
        else {
            //do something to notify use about the error
            callback(false,error)
        }
    }
}

func fetchSavedEventList(callback: (Bool,String?) -> Void) {
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"EventListData")
    
    let fetchedResults: [NSManagedObject]?
    do {
        fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if let results = fetchedResults {
            for event in results {
                let data = EventList(data: event)
                eventList.append(data)
            }
        sortFetchedEventList()
            getCurrentEventFromSavedData()
            callback(true,nil)
        }
        else {
            callback(false,"Empty")
        }
    }
    catch {
        callback(false,error as? String)
    }
}

func fetchSavedEventInformation(callback: (Bool,String?) -> Void) {
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"EventInformationData")
    
    do {
        let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [EventInformationData]
        if let results = fetchedResults {
            for event in results {
                currentEventInformation = EventInformation(data: event)
            }
            sortFetchedEventInformation()
            getScheduleForCurrentEvent()
            callback(true,nil)
        }
        else {
            callback(false,"empty")
        }
    }
    catch {
        callback(false,error as? String)
    }
}

func fetchSavedParticipantData(callback: (Bool,String?) -> Void) {
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"ParticipantData")
    
    do {
        let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [ParticipantData]
        if let results = fetchedResults {
            for participant in results {
                let data = ParticipantsInformation(participant: participant)
                allParticipantsInfo.append(data)
            }
            getSavedContacts()
            callback(true,nil)
        }
        else {
            callback(false,"empty")
        }
    }
    catch {
        callback(false,error as? String)
    }
}



//MARK: CoreData - Sort
func sortFetchedEventList() {
    for (var i = 0;i < eventList.count;i++) {
        var date1 = getDateFromString(eventList[i].startDate)!
        for (var j = 0;j < eventList.count;j++) {
            let date2 = getDateFromString(eventList[j].startDate)!
            if date1.compare(date2) == .OrderedAscending {
                let temp = eventList[i]
                eventList[i] = eventList[j]
                eventList[j] = temp
                date1 = date2
            }
        }
    }
}

func sortFetchedEventInformation() {
    //sorted Schedule
    if var tempSchedule = currentEventInformation?.schedule {
        for var i = 0;i < tempSchedule.count; i++ {
            var date1 = getDateFromString(tempSchedule[i].date)!
            for var j = 0;j < tempSchedule.count; j++ {
                let date2 = getDateFromString(tempSchedule[j].date)!
                if date1.compare(date2) == .OrderedAscending {
                    let temp = tempSchedule[i]
                    tempSchedule[i] = tempSchedule[j]
                    tempSchedule[j] = temp
                    date1 = date2
                }
            }
        }
        currentEventInformation?.schedule = tempSchedule
        
        for var k = 0;k < tempSchedule.count;k++ {
            let schedulePerDay = tempSchedule[k]
            for var i = 0;i < schedulePerDay.slots.count;i++ {
                var date1 = getTimeFromString(schedulePerDay.slots[i].time)!
                for var j = 0;j < schedulePerDay.slots.count; j++ {
                    let date2 = getTimeFromString(schedulePerDay.slots[j].time)!
                    if date1.compare(date2) == .OrderedAscending {
                        let temp = schedulePerDay.slots[i]
                        schedulePerDay.slots[i] = schedulePerDay.slots[j]
                        schedulePerDay.slots[j] = temp
                        date1 = date2
                    }
                }
            }
            currentEventInformation?.schedule[k] = schedulePerDay
        }
    }
}

//MARK: CoreData - Save
func saveFetchedEventList() {
    deleteSavedEventList()
    
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    for event in eventList {
        let entity =  NSEntityDescription.entityForName("EventListData",
            inManagedObjectContext:
            managedContext)
        
        let eventEntry = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        eventEntry.setValue(event.title, forKey: "title")
        eventEntry.setValue(event.year, forKey: "year")
        eventEntry.setValue(event.dateLocation, forKey: "dateLocation")
        eventEntry.setValue(event.startDate, forKey: "startDate")
        eventEntry.setValue(event.endDate, forKey: "endDate")
        eventEntry.setValue(event.url, forKey: "url")
        eventEntry.setValue(event.website, forKey: "website")
        eventEntry.setValue(event.jsonUrl, forKey: "jsonUrl")
        
        do {
            try managedContext.save()
        }
        catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}


func saveFetchedEventInformation() {
    deleteSavedEventInformation()
    
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    let eventInformationEntry = NSEntityDescription.insertNewObjectForEntityForName("EventInformationData", inManagedObjectContext: managedContext) as! EventInformationData
    
    //Adding Rooms
    if let rooms = currentEventInformation?.roomNames {
        for room in rooms {
            let roomEntry = NSEntityDescription.insertNewObjectForEntityForName("RoomsData", inManagedObjectContext: managedContext) as! RoomsData
            roomEntry.roomName = room.name
            roomEntry.roomTitle = room.title
            eventInformationEntry.addRooms(roomEntry)
        }
    }
    //Adding venues
    if let venues = currentEventInformation?.venueNames {
        for venue in venues {
            let venueEntry = NSEntityDescription.insertNewObjectForEntityForName("VenuesData", inManagedObjectContext: managedContext) as! VenuesData
            venueEntry.venueName = venue
            eventInformationEntry.addVenues(venueEntry)
        }
    }
    //Adding schedules
    if let scheduleForCurrentEvent = currentEventInformation?.schedule {
        for schedulePerDay in scheduleForCurrentEvent {
            let scheduleEntry = NSEntityDescription.insertNewObjectForEntityForName("ScheduleData", inManagedObjectContext: managedContext) as! ScheduleData
            scheduleEntry.date = schedulePerDay.date
            
            let slotsForDay = schedulePerDay.slots
            for slots in slotsForDay {
                let slotEntry = NSEntityDescription.insertNewObjectForEntityForName("SlotsData", inManagedObjectContext: managedContext) as! SlotsData
                slotEntry.time = slots.time
                
                let sessions = slots.sessions
                for session in sessions {
                    let sessionEntry = NSEntityDescription.insertNewObjectForEntityForName("SessionData", inManagedObjectContext: managedContext) as! SessionData
                    sessionEntry.title = session.title
                    sessionEntry.speakerName = session.speakerName
                    sessionEntry.startTime = session.startTime
                    sessionEntry.endTime = session.endTime
                    sessionEntry.roomName = session.roomName
                    sessionEntry.sectionType = session.sectionType
                    sessionEntry.technicalLevel = session.technicalLevel
                    if session.isBreak! {
                        sessionEntry.isBreak = 1
                    }
                    else {
                        sessionEntry.isBreak = 0
                    }
                    sessionEntry.talkDescription = session.description
                    sessionEntry.speakerBio = session.speakerBio
                    sessionEntry.jsonUrl = session.jsonUrl
                    
                    slotEntry.addSessions(sessionEntry)
                }
                scheduleEntry.addSlots(slotEntry)
            }
            eventInformationEntry.addSchedules(scheduleEntry)
        }
    }
    
    do {
        try managedContext.save()
    }
    catch {
        print("error is \(error)")
    }
}

func saveFetchedParticipantData() {
    deleteSavedParticipantData()
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    for contact in savedContacts {
        let participantEntry = NSEntityDescription.insertNewObjectForEntityForName("ParticipantData", inManagedObjectContext: managedContext) as! ParticipantData
        participantEntry.privateKey = contact.privateKey
        participantEntry.publicKey = contact.publicKey
        participantEntry.name = contact.fullName
        participantEntry.company = contact.company
        participantEntry.emailAddress = contact.email
        participantEntry.twitterHandle = contact.twitter
        participantEntry.mobileNumber = contact.phoneNumber
        participantEntry.jobTitle = contact.jobTitle
        participantEntry.participantDataUrl = contact.participantDataUrl
        do {
            try managedContext.save()
        }
        catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    for participant in allParticipantsInfo {
        if checkIfParticipantExistsInSavedContacts(participant) {
            //do nothing
        }
        else {
            let participantEntry = NSEntityDescription.insertNewObjectForEntityForName("ParticipantData", inManagedObjectContext: managedContext) as! ParticipantData
            participantEntry.privateKey = ""
            participantEntry.publicKey = participant.publicKey
            participantEntry.name = participant.fullName
            participantEntry.company = participant.company
            participantEntry.emailAddress = participant.email
            participantEntry.twitterHandle = participant.twitter
            participantEntry.mobileNumber = participant.phoneNumber
            participantEntry.jobTitle = participant.jobTitle
            participantEntry.participantDataUrl = participant.participantDataUrl
            do {
                try managedContext.save()
            }
            catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

func checkIfParticipantExistsInSavedContacts(participant: ParticipantsInformation) -> Bool {
    for contact in savedContacts {
        if participant.publicKey == contact.publicKey {
            return true
        }
    }
    return false
}

//MARK: CoreData - Delete
func deleteSavedEventList() {
    deleteSavedData("EventListData")
}

func deleteSavedEventInformation() {
   deleteSavedData("EventInformationData")
}

func deleteSavedParticipantData() {
    deleteSavedData("ParticipantData")
}

func deleteSavedData(entityName: String) {
    let appDelegate =
    UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:entityName)
    
    let fetchedResults: [NSManagedObject]?
    do {
        fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if let results = fetchedResults {
            for event in results {
                managedContext.deleteObject(event)
            }
        }
    }
    catch {
        print("error: \(error)")
    }
}




