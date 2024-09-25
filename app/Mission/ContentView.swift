//
//  ContentView.swift
//  Mission
//
//  Created by user257756 on 9/24/24.
//
import SwiftUI
import UIKit

// This is the home view with 'MISSION' and a button 'Get Task'
struct HomeView: View {
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
                Spacer()
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.2)
                NavigationLink(destination: TaskView()) {
                    Text("Get Task")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                .padding()
            }
        }
    }
}

// This is the second view that shows the text 'Laugh loudly'
struct TaskView: View {
    
    // List of possible tasks
    let tasks = [
        "Laugh loudly",
        "Run in place for 30 seconds",
        "Dance for 1 minute",
        "Do 10 push-ups",
        "Sing a song"
    ]
    
    // Track the selected task and retry count
    @State private var selectedTask: String = ""
    @State private var retryCount: Int = 0
    @Environment(\.presentationMode) var presentationMode // To return to the home view
    
    var body: some View {
        VStack {
            Text(selectedTask)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding()
            
            Spacer() // Push content up to leave space for the button at the bottom
            
            // Retry button with retry count in the bottom-right corner
            HStack {
                Spacer() // Push the button to the right
                
                if retryCount < 3 {
                    Button(action: {
                        selectRandomTask()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise") // Icon from SF Symbols
                            Text("\(retryCount + 1)/3") // Display retry count
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        // Return to the home screen after 3 retries
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "house.fill") // Icon for returning home
                            Text("Return to Home")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
            }
            .padding() // Add some space from the edges
        }
        .onAppear {
            selectRandomTask()
        }
    }
    
    // Function to select a random task and update retry count
    func selectRandomTask() {
        selectedTask = tasks.randomElement() ?? "No task available"
        retryCount += 1
    }
}
// Preview section for HomeView
#Preview {
    HomeView()
}
