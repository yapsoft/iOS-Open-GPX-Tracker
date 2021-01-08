//
//  ComplicationController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 5/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import ClockKit

let ComplicationDistanceIdentifier = "ComplicationTypeCondition"
let ComplicationSpeedIdentifier="ComplicationTypeSpeed"

///
class ComplicationController: NSObject, CLKComplicationDataSource {
    
    
    /// Declares the list of supported complications
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        
        // Families (how they look)
        // https://developer.apple.com/design/human-interface-guidelines/watchos/overview/complications/
        // Define complication descriptor
        //https://developer.apple.com/documentation/clockkit/clkcomplicationdatasource/3555131-getcomplicationdescriptors
        let supportedFamilies = CLKComplicationFamily.allCases
        
        // Create the descriptors
        let distanceDescriptor = CLKComplicationDescriptor(
            identifier: ComplicationDistanceIdentifier,
            displayName: "Distance",
            supportedFamilies: supportedFamilies)
        
        let speedDescriptor = CLKComplicationDescriptor(
            identifier: ComplicationSpeedIdentifier,
            displayName: "Speed",
            supportedFamilies: supportedFamilies)
        
        handler([distanceDescriptor,speedDescriptor])
    }
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
