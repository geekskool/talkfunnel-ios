//
//  FetchData.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 12/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

var eventList = [EventList]()
var currentEvent: EventList?
var currentEventInformation: EventInformation?

//The following two are is the info for the event that is happening at present or the very next event going to happen , for the scan contact url
var theEvent: EventList?
var theEventInformation: EventInformation?

var schedule = [[Session]]()

var allParticipantsInfo = [ParticipantsInformation]()
var scannedParticipantInfo: ParticipantsInformation?

var scannedContactPublicKey: String?
var scannedContactPrivateKey: String?
var userLogInString: String?
var userAccessToken: String?
var userTokenType: String?

var isScanComplete = false
var isUserLoggedIn = false {
willSet(newValue) {
    if newValue {
        retrieveUserData()
    }
}
}


private struct constants {
    static let EventListUrl = "https://talkfunnel.com/json"
    static let UserLoginUrl = "http://auth.hasgeek.com/auth?client_id=eDnmYKApSSOCXonBXtyoDQ&scope=id+email+phone+organizations+teams+com.talkfunnel:*&response_type=token"
}

private struct defaultsKeys {
    static let userAccessToken = "Access Token"
    static let userTokenType = "Token Type"
    static let contactPublicKey = "Public Key"
    static let contactPrivateKey = "Private Key"
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

func fetchDataForEvent(callback: Bool -> Void) {
    HttpRequest(url: (currentEvent?.jsonUrl)!) {
        (data, error) -> Void in
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if error != nil {
                print("EventInfo error is \(error)")
                callback(false)
            }
            else {
                currentEventInformation = EventInformation(data: data)
                getScheduleForCurrentEvent()
                callback(true)
            }
        }
    }
}


//Working with The List of Events
func fetchDataForEventList(callback: (Bool,String?) -> Void) {
    HttpRequest(url: constants.EventListUrl) {
        (data, error) -> Void in
        
        //this implementation happens in another queue but we need to get it back in to our main queue cause its UI related stuff
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if error != nil {
                print("EventListError: \(error)")
                callback(false,error)
            }
            else {
                if let spaces = data["spaces"] as? NSArray {
                    for events in spaces {
                        if let eventInfo = events as? NSDictionary {
                            let dict = EventList(data: eventInfo)
                            if isEventAfterToday(dict) {
                                eventList.append(dict)
                            }
                        }
                    }
                    getCurrentEvent()
                    fetchDataForEvent({ (doneFetching) -> Void in
                        if doneFetching {
                            callback(true,nil)
                        }
                        else {
                            callback(false,nil)
                        }
                    })
                }
            }
        }
    }
}

//shared pref

func getLocalData() {
    let defaults = NSUserDefaults.standardUserDefaults()
    userAccessToken = defaults.valueForKey(defaultsKeys.userAccessToken) as? String
    userTokenType = defaults.valueForKey(defaultsKeys.userTokenType) as? String
    if userAccessToken != nil && userTokenType != nil {
        isUserLoggedIn = true
    }
}

func addToLocalData() {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setValue(userAccessToken, forKey: defaultsKeys.userAccessToken)
    defaults.setValue(userTokenType, forKey: defaultsKeys.userTokenType)
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






