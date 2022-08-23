//
//  CampaignList.swift
//  St Jude
//
//  Created by Ben Cardy on 18/08/2022.
//

import SwiftUI

struct CampaignList: View {
    
    @State private var fundraisingEvent: FundraisingEvent? = nil
    @State private var campaigns: [Campaign] = []
    @StateObject private var apiClient = ApiClient.shared
    
    var body: some View {
        Group {
            if let fundraisingEvent = fundraisingEvent {
                VStack {
                    VStack(spacing: 0) {
                        Text(fundraisingEvent.cause.name)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        //                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.bottom, 2)
                        Text(fundraisingEvent.name)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)
                        if let percentageReached =  fundraisingEvent.percentageReached {
                            ProgressBar(value: .constant(Float(percentageReached)), fillColor: fundraisingEvent.colors.highlightColor)
                                .frame(height: 15)
                                .padding(.bottom, 2)
                        }
                        Text(fundraisingEvent.amountRaised.description(showFullCurrencySymbol: false))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        if let percentageReachedDesc = fundraisingEvent.percentageReachedDescription {
                            Text("\(percentageReachedDesc) of \(fundraisingEvent.goal.description(showFullCurrencySymbol: false))")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .opacity(0.8)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(fundraisingEvent.colors.backgroundColor)
                    .cornerRadius(10)
                    .padding()
                    
                    Link("Visit the fundraiser!", destination: URL(string: "https://stjude.org/relay")!)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 20)
                        .background(fundraisingEvent.colors.backgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    //                        .frame(minHeight: 80)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                    
                    Text("Fundraisers")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    List {
                        //                    .background(LinearGradient(colors: [
                        //                        Color(.sRGB, red: 43 / 255, green: 54 / 255, blue: 61 / 255, opacity: 1),
                        //                        Color(.sRGB, red: 51 / 255, green: 63 / 255, blue: 72 / 255, opacity: 1)
                        //                    ], startPoint: .bottom, endPoint: .top))
                        
                        
                        ForEach(campaigns, id: \.id) { campaign in
                            NavigationLink(destination: ContentView(vanity: campaign.user.slug, slug: campaign.slug, user: campaign.user.username).navigationTitle(campaign.name)) {
                                VStack(alignment: .leading) {
                                    Text(campaign.name)
                                        .font(.headline)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    HStack(alignment: .top) {
                                        Text(campaign.user.username)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(campaign.totalRaised.description(showFullCurrencySymbol: false))
                                            .font(.title)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
//                .listRowSeparator(.hidden)
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            Task {
                do {
                    fundraisingEvent = try await AppDatabase.shared.fetchRelayFundraisingEvent()
                    dataLogger.notice("Fetched stored fundraiser")
                    if let fundraisingEvent = fundraisingEvent {
                        dataLogger.notice("Fetched stored fundraiser")
                        campaigns = try await AppDatabase.shared.fetchAllCampaigns(for: fundraisingEvent)
                        dataLogger.notice("Fetched stored campaigns")
                    }
                } catch {
                    dataLogger.error("Failed to fetch stored fundraiser: \(error.localizedDescription)")
                }
                await refresh()
            }
        }
    }
    
    func refresh() async {
        let response: TiltifyCauseResponse
        do {
            response = try await apiClient.fetchCause()
        } catch {
            dataLogger.error("Fetching cause failed: \(error.localizedDescription)")
            return
        }
        let apiEvent = FundraisingEvent(from: response.data)
        do {
            if let existingEvent = fundraisingEvent {
                fundraisingEvent = try await AppDatabase.shared.updateFundraisingEvent(apiEvent, from: existingEvent)
            } else {
                fundraisingEvent = try! await AppDatabase.shared.saveFundraisingEvent(apiEvent)
            }
        } catch {
            dataLogger.error("Updating stord fundraiser failed: \(error.localizedDescription)")
        }
        campaigns = await response.data.fundraisingEvent.publishedCampaigns.edges.asyncMap { apiCampaign in
            let storedCampaign: Campaign?
            do {
                storedCampaign = try await AppDatabase.shared.fetchCampaign(with: apiCampaign.node.publicId)
            } catch {
                return Campaign(from: apiCampaign.node, fundraiserId: apiEvent.id)
            }
            
            let campaign: Campaign
            if let storedCampaign = storedCampaign {
                campaign = storedCampaign.update(fromCauseCampaign: apiCampaign.node, fundraiserId: apiEvent.id)
            } else {
                campaign = Campaign(from: apiCampaign.node, fundraiserId: apiEvent.id)
            }
            do {
                return try await AppDatabase.shared.saveCampaign(campaign)
            } catch {
                return campaign
            }
        }
    }
}

struct CampaignList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignList()
        }
    }
}
