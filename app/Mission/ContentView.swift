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



struct TaskView: View {
    @StateObject private var taskViewModel = TaskViewModel()  // Create the TaskViewModel to fetch tasks
    @State private var currentTaskIndex: Int = 0  // Tracks which task to show
    @State private var retryCount: Int = 0  // Tracks retry attempts
    @Environment(\.presentationMode) var presentationMode  // To return to the home view

    var body: some View {
        VStack {
            // Display the fetched task's name or a default message
            if taskViewModel.tasks.indices.contains(currentTaskIndex) {
                Text("Task: \(taskViewModel.tasks[currentTaskIndex])")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
            } else {
                Text("Fetching Task...")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
            }

            Spacer()  // Push content up to leave space for the button at the bottom

            // Retry button with retry count in the bottom-right corner
            HStack {
                Spacer()  // Push the button to the right

                if retryCount < 3 {
                    Button(action: {
                        if currentTaskIndex < taskViewModel.tasks.count - 1 {
                            currentTaskIndex += 1  // Show the next task
                        }
                        retryCount += 1
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")  // Icon from SF Symbols
                            Text("\(retryCount + 1)/3")  // Display retry count
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
                            Image(systemName: "house.fill")  // Icon for returning home
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
            .padding()  // Add some space from the edges
        }
        .onAppear {
            taskViewModel.fetchThreeRandomTasks()  // Fetch three random tasks when the view appears
        }
    }
}

// Preview section for HomeView
#Preview {
    HomeView()
}
