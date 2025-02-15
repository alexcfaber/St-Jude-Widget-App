//
//  FundraiserListItem.swift
//  St Jude
//
//  Created by Ben Cardy on 24/08/2022.
//

import SwiftUI

struct FundraiserListItem: View {
    
    let campaign: Campaign
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .top) {
                    if let url = URL(string: campaign.avatar?.src ?? "") {
                        AsyncImage(
                            url: url,
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 45)
                            },
                            placeholder: {
                                ProgressView()
                                    .frame(width: 45, height: 45)
                            }
                        )
                        .cornerRadius(5)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(campaign.title)
                            .multilineTextAlignment(.leading)
                            .font(.headline)
                        Text(campaign.user.username)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                Text(campaign.totalRaised.description(showFullCurrencySymbol: false))
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                if let percentageReached = campaign.percentageReached {
                    ProgressBar(value: .constant(Float(percentageReached)), fillColor: .accentColor)
                        .frame(height: 10)
                }
            }
        }
        .foregroundColor(.primary)
    }
}
