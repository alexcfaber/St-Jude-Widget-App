//
//  WidgetEntryView.swift
//  WidgetEntryView
//
//  Created by David on 23/08/2021.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.widgetFamily) var family
    
    @Binding var campaign: TiltifyWidgetData
    let showMilestones: Bool
    let preferFutureMilestones: Bool
    let showFullCurrencySymbol: Bool
    let showGoalPercentage: Bool
    let showMilestonePercentage: Bool
    let useTrueBlackBackground: Bool
    var forceHidePreviousMilestone: Bool = false

    
    var showTwoMilestones: Bool {
        if self.forceHidePreviousMilestone { return false }
        return (isLargeSize(family: family) || !DeviceType.isInWidget()) || campaign.nextMilestone == nil
    }
    
    var titleFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        case .systemMedium:
            return .title2
        default:
            return .largeTitle
        }
    }
    
    var raisedAmountFont: Font {
        switch family {
        case .systemSmall:
            return .headline
        default:
            return .largeTitle
        }
    }
    
    var backgroundColors: [Color] {
        if useTrueBlackBackground {
            return [Color.black]
        } else {
            return [
                Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1),
                Color(.sRGB, red: 51 / 255, green: 63 / 255, blue: 72 / 255, opacity: 1)
            ]
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 5) {
           
            CampaignTitle(name: campaign.name)
             
            Spacer()
            
            if let percentageReached = campaign.percentageReached {
                ProgressBar(value: .constant(Float(percentageReached)), fillColor: Color(.sRGB, red: 254 / 255, green: 206 / 255, blue: 52 / 255, opacity: 1))
                    .frame(height: 15)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    
                    Text(campaign.totalRaisedDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                        .font(raisedAmountFont)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .accessibility(label: Text(campaign.totalRaisedAccessibilityDescription(showFullCurrencySymbol: showFullCurrencySymbol)))
                    
                    if showGoalPercentage && family == .systemMedium && DeviceType.isInWidget() {
                        VStack(alignment: .leading) {
                            Text(campaign.percentageReachedDescription ?? "Unknown")
                            Text(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol))
                        }
                        .font(.caption)
                    }
                    if #available(iOS 15.0, *), showGoalPercentage, isExtraLargeSize(family: family) && DeviceType.isInWidget() {
                            Spacer()
                            Text("\(campaign.percentageReachedDescription ?? "Unknown") of \(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol))")
                    }
                }
                
                if showGoalPercentage,
                   family == .systemLarge || !DeviceType.isInWidget() {
                    Text("\(campaign.percentageReachedDescription ?? "Unknown") of \(campaign.goalDescription(showFullCurrencySymbol: showFullCurrencySymbol))")
                }
                
                if showGoalPercentage,
                   family == .systemSmall && DeviceType.isInWidget() {
                    Text(campaign.percentageReachedDescription ?? "Unknown")
                        .font(.caption)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(campaign.totalRaisedAccessibilityDescription(showFullCurrencySymbol: showFullCurrencySymbol)))
            
            if showMilestones && family != .systemSmall {
                if showTwoMilestones,
                   !preferFutureMilestones || campaign.futureMilestones.count <= 1,
                   let milestone = campaign.previousMilestone {
                    MilestoneView(title: "Previous milestone", data: campaign, milestone: milestone, showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage)
                }
                
                if let milestone = campaign.nextMilestone {
                    MilestoneView(title: "Next milestone", data: campaign, milestone: milestone, showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage)
                }
                
                if showTwoMilestones,
                   preferFutureMilestones && campaign.futureMilestones.count > 1,
                   1 < campaign.futureMilestones.endIndex,
                   let milestone = campaign.futureMilestones[1] {
                    MilestoneView(title: "Upcoming milestone", data: campaign, milestone: milestone, showFullCurrencySymbol: showFullCurrencySymbol, showMilestonePercentage: showMilestonePercentage)
                }
            }
            
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(LinearGradient(colors: backgroundColors, startPoint: .bottom, endPoint: .top))
    }
}

struct EntryViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            EntryView(campaign: .constant(sampleCampaignSingleMilestone), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, useTrueBlackBackground: false)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaignTwoMilestones), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, useTrueBlackBackground: true)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaignThreeMilestones), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, useTrueBlackBackground: true)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaign), showMilestones: true, preferFutureMilestones: true, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, useTrueBlackBackground: true)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
            EntryView(campaign: .constant(sampleCampaign), showMilestones: true, preferFutureMilestones: false, showFullCurrencySymbol: false, showGoalPercentage: true, showMilestonePercentage: true, useTrueBlackBackground: true)
                .frame(width: 300, height: 378)
                .cornerRadius(15)
        }
    }
}
