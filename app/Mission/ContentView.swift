//
//  ContentView.swift
//  Mission
//
//  Created by user257756 on 9/24/24.
//
import SwiftUI
import UIKit

let darksandybrown = Color(red: 234/255, green: 230/255, blue: 212/255)
let lightsandybrown = Color(red: 244/255, green: 240/255, blue: 242/255)

// This is the home view with 'MISSION' and a button 'Get Task'
struct HomeView: View {
    @State private var name: String = "" 
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                Text("MISSION")
                    .font(.custom("Courier", size: 70))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundStyle(Color.black)
                
                Spacer()
                
                TextField("Enter your name", text: $name)
                    .padding()
                    .frame(height: UIScreen.main.bounds.height * 0.05)
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .padding(.bottom, 40)
                
                Spacer()
                
                NavigationLink(destination: StartGame(playerName: name)) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(lightsandybrown)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(Color.gray, lineWidth: 2))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // Save the entered name to UserDefaults when the button is tapped
                    storeUserName()})
                .padding(.bottom, 30)
                
                Spacer()
                
                NavigationLink(destination: StartGame(playerName: name)) {
                    Text("Join Game")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(lightsandybrown)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(Color.gray, lineWidth: 2))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // Save the entered name to UserDefaults when the button is tapped
                    storeUserName()})
                .padding(.bottom, 30)
                
                Spacer()
                
                NavigationLink(destination: HowToPlayView()) {
                    Text("How To Play")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(lightsandybrown)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(Color.gray, lineWidth: 2))
                }
                
                Spacer()
                
                .padding()
            }
            .background(darksandybrown)
        }
    }


    private func storeUserName() {
        UserDefaults.standard.set(self.name, forKey: "userName")}
}

struct StartGame: View {
    let playerName: String  // Player's name passed in from HomeView
    
    // Generate a unique game code
    let gameCode = UUID().uuidString.prefix(6).uppercased()

    var body: some View {
        VStack {
            Text("Welcome, \(playerName)")
                .font(.title)
                .padding()
            
            Text("Your Game Code is:")
                .font(.headline)
                .padding(.top, 20)

            Text(gameCode)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding()
                .background(Color.yellow)
                .cornerRadius(8)
                .padding(.bottom, 40)

            Text("Share this code with others to join your game.")
                .font(.subheadline)
                .padding()

            Spacer()

            Button(action: {
                print("Quit Game")  // Placeholder for quit game action
            }) {
                Text("Quit Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView()
}

