//
//  File.swift
//  
//
//  Created by Costantino, Diego on 2022-05-31.
//

import Foundation
import Amplify
#if canImport(UIKit)
import UIKit
#endif

class AWSPinpointAnalyticsNotifications: AWSPinpointAnalyticsNotificationsBehavior {
    private static let AWSDataKey = "data"
    private static let AWSPinpointKey = "pinpoint"
    
    let shared = AWSPinpointAnalyticsNotifications()
    
    private init() {}
    
    func interceptDidFinishLaunchingWithOptions(launchOptions: LaunchOptions) -> Bool {
        guard let notificationPayload = remoteNotificationPayload(fromLaunchOptions: launchOptions),
              isValidPinpointNotification(payload: notificationPayload) else {
            return true
        }
        
        let (eventSource, pinpointMetadata) = pinpointMetadata(fromPayload: notificationPayload)
        
        // TODO: add event to globalsource metatadata
        
        // TODO: record launch because of notification
        
        return true
    }
    
    func interceptDidRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        
    }
    
    func interceptDidReceiveRemoteNotification(userInfo: UserInfo, pushEvent: AWSPinpointPushEvent) {
        
    }
    
    func interceptDidReceiveRemoteNotification(userInfo: UserInfo, pushEvent: AWSPinpointPushEvent, shouldHandleNotificationDeepLink: Bool) {
        
    }
    
    
    func isValidPinpointNotification(payload: NotificationPayload) -> Bool {
        pinpointPayloadFromNotificationPayload(notification: payload) != nil
    }
    
    func pinpointPayloadFromNotificationPayload(notification: NotificationPayload) -> [String: Any]? {
        guard let dataPayload = notification[Self.AWSDataKey] as? [String: Any],
              let pinpointMetadata = dataPayload[Self.AWSPinpointKey] as? [String: Any] else {
            return nil
        }
        return pinpointMetadata
    }
    
    func pinpointMetadata(fromPayload payload: NotificationPayload) -> (EventSourceType, NotificationPayload?) {
        var metadata: (EventSourceType, NotificationPayload?) = (.unknown, nil)
        
        guard let pinpointPayload = pinpointPayloadFromNotificationPayload(notification: payload) else {
            return metadata
        }
        
        if let campaignMetadata = pinpointPayload[EventSourceType.campaign.rawValue] as? NotificationPayload {
            metadata = (.campaign, campaignMetadata)
            self.log.verbose("Found Pinpoint campaign with attributes: \(campaignMetadata)")
        
        } else if let journeyMetadata = pinpointPayload[EventSourceType.journey.rawValue] as? NotificationPayload {
            metadata = (.journey, journeyMetadata)
            self.log.verbose("Found Pinpoint journey with attributes: \(journeyMetadata)")
        }
        
        if metadata.1 == nil {
            fatalError("Pinpoint push payload not found")
        }
        
        return metadata
    }
    
    
    func remoteNotificationPayload(fromLaunchOptions launchOptions: LaunchOptions) -> NotificationPayload? {
#if canImport(UIKit)
        return launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? NotificationPayload
#else
        return nil
#endif
    }
}

// MARK: - AWSPinpointAnalyticsNotifications + DefaultLogger
extension AWSPinpointAnalyticsNotifications: DefaultLogger {}


