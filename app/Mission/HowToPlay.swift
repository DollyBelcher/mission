//
//  HowToPlay.swift
//  Mission
//
//  Created by dolly.belcher on 26/09/2024.
//

import SwiftUI


struct HowToPlayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("How to Play")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(Color.white)

            // Subtitle or Introduction
            Text("Follow these instructions to play the game successfully!")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            HStack {
                Image(systemName: "1.circle.fill") // Icon for Step 1
                    .foregroundColor(.blue)
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text("Step 1: Create or Join a Game")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Text("You can either start a new game by clicking 'Start Game' or join an existing game by selecting 'Join Game'.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Image(systemName: "2.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text("Step 2: Complete Your Mission")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Text("Try to complete the mission without your friends or family noticing")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: "3.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 40))
                VStack(alignment: .leading) {
                    Text("Step 3: Guess Eachother's Mission")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    Text("The host will set a timer for the game. This will display across everyone's screens and notify you when the time is up.")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }

            // Additional Notes or Tips
            Text("Good luck! Remember, don't get caught.")
                .font(.body)
                .italic()
                .foregroundColor(.gray)
                .padding(.top, 30)

            Spacer() // Pushes content up to avoid touching the bottom
        }
        .padding() // Adds padding around the entire view
        .navigationBarTitle("How to Play", displayMode: .inline) // Optional Navigation Bar Title
        .background(Color.black)
    }
}

struct HowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView()
    }
}
