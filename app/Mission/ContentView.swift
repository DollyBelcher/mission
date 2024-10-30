//
//  ContentView.swift
//  Mission
//
//  Created by user257756 on 9/24/24.
//
import SwiftUI
import Firebase
import FirebaseDatabase
import UserNotifications
import UIKit



let darksandybrown = Color(red: 234/255, green: 230/255, blue: 212/255)
let lightsandybrown = Color(red: 244/255, green: 240/255, blue: 242/255)

struct HomeView: View {
    @State private var name: String = ""
    @State private var gameCode: String? = nil // Store generated game code
    @State private var path = NavigationPath() // Manage the navigation stack

    var body: some View {
        NavigationStack(path: $path) {  // NavigationStack is the new way for navigation in iOS 16+
            VStack {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.25)

                Text("MISSION")
                    .font(.custom("Courier", size: 70))
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.black)

                Spacer()

                TextField("Enter your name", text: $name)
                    .padding()
                    .frame(height: UIScreen.main.bounds.height * 0.05)
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .cornerRadius(10)
                    .padding(.bottom, 40)

                Spacer()

                // Start Game Button
                Button(action: {
                    generateGameCodeAndNavigate()
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                Spacer()
            }
            // Navigation destination based on the value pushed onto the navigation stack
            .navigationDestination(for: String.self) { gameCode in
                StartGameView(playerName: name, gameCode: gameCode)
            }
            .padding()
        }
    }

    // Function to generate a game code and navigate to the next view
    private func generateGameCodeAndNavigate() {
        let gameCode = generateGameCode()
        self.gameCode = gameCode
        self.path.append(gameCode)  // Push gameCode onto the navigation stack
    }

    // Function to generate a random 6-character game code
    private func generateGameCode() -> String {
        return String(UUID().uuidString.prefix(6)).uppercased()
    }

    private func storeUserName() {
        UserDefaults.standard.set(self.name, forKey: "userName")
    }
}


struct StartGameView: View {
    let playerName: String  // Passed from HomeView
    let gameCode: String    // Passed from HomeView
    @State private var players: [String] = [] // List of player names in the game
    @State private var gameTime: String = ""  // Input for the game time in minutes
    @State private var gameState: String = "waiting" // Track the game state
    @State private var timerActive: Bool = false  // Track if the timer is active
    @State private var showError: Bool = false  // Handle errors
    @State private var errorMessage: String? = nil  // Error message
    @State private var path = NavigationPath() // Manage the navigation stack

    var body: some View {
        NavigationStack(path: $path) { // Use NavigationStack instead of NavigationView
            VStack {
                // Display the game code
                Text("Game Code: \(gameCode)")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .padding(.bottom, 40)

                Text("Welcome, \(playerName)")
                    .font(.title)
                    .padding(.bottom, 20)

                // Input for game time in minutes
                if !timerActive {
                    TextField("Enter game time (minutes)", text: $gameTime)
                        .padding()
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }

                // Display the real-time list of players
                Text("Players:")
                    .font(.headline)
                    .padding(.bottom, 10)

                if !players.isEmpty {
                    ForEach(players, id: \.self) { player in
                        Text(player)
                            .font(.body)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                } else {
                    Text("No players have joined yet.")
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }

                Spacer()

                // Start Game button (disabled if no time is entered)
                if !timerActive {
                    Button(action: {
                        startGame()
                    }) {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(gameTime.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(gameTime.isEmpty)  // Disable if no time is entered
                }

                Spacer()
            }
            .navigationDestination(for: String.self) { gameCode in
                GameCountdownView(gameCode: gameCode, gameTime: Int(gameTime) ?? 0)
            }
            .onAppear {
                observePlayers()
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .padding()
        }
    }

    // Function to start the game and navigate to countdown
    private func startGame() {
        guard let minutes = Int(gameTime), minutes > 0 else {
            errorMessage = "Invalid time input."
            showError = true
            return
        }

        FirebaseHelper.assignRandomTasks(for: playerName, in: gameCode) { success in
            if success {
                print("Tasks assigned successfully.")
                // Handle success (e.g., update UI or move to the next screen)
            } else {
                print("Failed to assign tasks.")
                // Handle failure (e.g., show an error message)
            }
        }

        let gameRef = Database.database().reference().child("games").child(gameCode)

        // Update the game state to "in progress" and set the timer
        let currentTime = Date().timeIntervalSince1970  // Get the current time
        let updatedGameData: [String: Any] = [
            "gameState": "in progress",
            "timer": minutes * 60,  // Convert minutes to seconds
            "startTime": currentTime  // Store the start time in Firebase
        ]

        gameRef.updateChildValues(updatedGameData) { error, _ in
            if let error = error {
                self.errorMessage = "Error starting game: \(error.localizedDescription)"
                self.showError = true
            } else {
                print("Game \(gameCode) started with \(minutes) minutes.")
                path.append(gameCode)  // Push the gameCode onto the navigation stack
            }
        }
    }

    // Function to observe players in real time
    private func observePlayers() {
        let playersRef = Database.database().reference().child("games").child(gameCode).child("players")

        playersRef.observe(.value) { snapshot in
            var updatedPlayers: [String] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let playerData = childSnapshot.value as? [String: Any],
                   let playerName = playerData["name"] as? String {
                    updatedPlayers.append(playerName)
                }
            }
            self.players = updatedPlayers
        }
    }
}



struct JoinGameView: View {
    let playerName: String  // Passed from HomeView
    @State private var gameCode: String = ""  // User inputs game code
    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isGameJoined: Bool = false // Track if the player has joined the game
    @State private var gameState: String = "waiting"  // Track the game state
    @State private var remainingTime: Int = 0  // Remaining time in seconds
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.25)

            Text("Enter Game Code")
                .font(.title)
                .padding()

            // TextField for entering game code
            TextField("Enter game code", text: $gameCode)
                .padding()
                .frame(height: UIScreen.main.bounds.height * 0.05)
                .background(Color.white)
                .foregroundColor(Color.black)
                .cornerRadius(10)
                .padding(.bottom, 40)

            // Join game button
            Button(action: {
                if gameCode.isEmpty {
                    showError = true
                } else {
                    joinGame()  // Call joinGame() on button press
                }
            }) {
                Text("Join Game")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text("Please enter a valid game code."), dismissButton: .default(Text("OK")))
            }
            .padding(.bottom, 20)

            Spacer()

            if isGameJoined {
                // Show the countdown timer if the game is in progress
                Text("Time Remaining: \(formattedTime(remainingTime))")
                    .font(.largeTitle)
                    .padding(.top, 20)
            }

            Spacer()
        }
        .onDisappear {
            timer?.invalidate()  // Stop the timer when leaving the view
        }
        .padding()
    }

    // Function to join a game using the entered game code
    private func joinGame() {
        let gameRef = Database.database().reference().child("games").child(gameCode)

        // Check if the game exists
        gameRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                self.errorMessage = "Game not found!"
                self.showError = true
                return
            }

            // Add player to the game in Firebase
            let playerData: [String: Any] = [
                "name": playerName
            ]

            gameRef.child("players").child(playerName).setValue(playerData) { error, _ in
                if let error = error {
                    self.errorMessage = "Error joining game: \(error.localizedDescription)"
                    self.showError = true
                } else {
                    print("Player \(playerName) successfully added to game \(gameCode)")
                    // Mark the player as joined
                    self.isGameJoined = true
                    self.observeGameState()  // Now start observing the game state
                }
            }
        }
    }

    // Function to observe the game state and timer in real time
    private func observeGameState() {
        let gameRef = Database.database().reference().child("games").child(gameCode)

        // Observe changes in the game state and timer
        gameRef.observe(.value) { snapshot in
            guard let gameData = snapshot.value as? [String: Any] else { return }
            
            self.gameState = gameData["gameState"] as? String ?? "waiting"
            
            // When the game state changes to "in progress"
            if self.gameState == "in progress" {
                let startTime = gameData["startTime"] as? TimeInterval ?? 0
                let timerDuration = gameData["timer"] as? Int ?? 0
                self.startCountdown(from: startTime, with: timerDuration)
            }
        }
    }

    // Function to start the countdown based on the host's timer
    private func startCountdown(from startTime: TimeInterval, with timerDuration: Int) {
        let currentTime = Date().timeIntervalSince1970
        let elapsedTime = Int(currentTime - startTime)
        let remainingTime = timerDuration - elapsedTime

        // Ensure the remaining time is not negative
        self.remainingTime = max(remainingTime, 0)

        if self.remainingTime > 0 {
            // Start a timer to update the countdown in real-time
            timer?.invalidate()  // Invalidate any existing timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.timer?.invalidate()
                    self.sendGameEndNotification()
                }
            }
        } else {
            sendGameEndNotification()
        }
    }

    // Function to format the time in MM:SS format
    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Send a notification to the player when the game ends
    private func sendGameEndNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Game Over!"
        content.body = "The game has finished. Check your results."
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "gameEndNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Game end notification scheduled successfully.")
            }
        }
    }
}

struct GameLobbyView: View {
    let playerName: String  // Passed from JoinGameView
    let gameCode: String    // Passed from JoinGameView
    @State private var players: [String] = [] // List of player names in the game

    var body: some View {
        VStack {
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.25)

            // Welcome message for the player
            Text("Welcome \(playerName)")
                .font(.title)
                .padding(.top, 20)

            Divider()
                .padding(.vertical, 20)

            // List of players
            Text("PLAYERS:")
                .font(.headline)
                .padding(.bottom, 10)

            if !players.isEmpty {
                ForEach(players, id: \.self) { player in
                    Text(player)
                        .font(.body)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            } else {
                Text("No players have joined yet.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }

            Spacer()
        }
        .onAppear {
            observePlayers()
        }
        .padding()
    }

    // Function to observe players in real time (called after joining the game)
    private func observePlayers() {
        let playersRef = Database.database().reference().child("games").child(gameCode).child("players")
        
        // Listen for changes in the players list
        playersRef.observe(.value) { snapshot in
            var updatedPlayers: [String] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let playerData = childSnapshot.value as? [String: Any],
                   let playerName = playerData["name"] as? String {
                    updatedPlayers.append(playerName)
                }
            }
            self.players = updatedPlayers
        }
    }
}


struct GameView: View {
    let playerName: String
    let gameCode: String
    @State private var tasks: [String] = []
    @State private var gameState: String = "waiting"  // Default game state
    @State private var timer: Int = 60  // Default timer (in seconds)

    var body: some View {
        VStack {
            // Display game information
            Text("Game Code: \(gameCode)")
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .padding()
                .background(Color.yellow)
                .cornerRadius(8)
                .padding(.bottom, 20)

            // Display player information
            Text("Welcome, \(playerName)")
                .font(.title)
                .padding(.bottom, 20)

            // Display the assigned tasks
            Text("Your Tasks")
                .font(.headline)
                .padding(.bottom, 10)

            // Loop through the tasks and display them
            ForEach(tasks, id: \.self) { task in
                Text(task)
                    .font(.body)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Spacer()

            // Display the game state
            Text("Game Status: \(gameState.capitalized)")
                .font(.subheadline)
                .padding(.top, 20)

            // Display a countdown timer, if the game uses one
            if timer > 0 {
                Text("Time Remaining: \(timer) seconds")
                    .font(.title2)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .onAppear {
            // Load game data such as tasks and game state
            fetchGameData()
        }
        .padding()
    }

    // Function to fetch game data such as tasks and game state
    private func fetchGameData() {
        let gameRef = Database.database().reference().child("games").child(gameCode)

        // Fetch the player's tasks from Firebase
        gameRef.child("players").child(playerName).child("tasks").observeSingleEvent(of: .value) { snapshot in
            if let tasksData = snapshot.value as? [String] {
                self.tasks = tasksData  // Update tasks
            } else {
                print("Failed to load tasks.")
            }
        }

        // Fetch the current game state and timer from Firebase
        gameRef.observeSingleEvent(of: .value) { snapshot in
            if let gameData = snapshot.value as? [String: Any] {
                self.gameState = gameData["gameState"] as? String ?? "waiting"
                self.timer = gameData["timer"] as? Int ?? 60
            }
        }
    }
}


struct GameCountdownView: View {
    let gameCode: String
    let gameTime: Int  // Time in seconds
    @State private var remainingTime: Int  // Track the remaining time
    @State private var timer: Timer? = nil

    init(gameCode: String, gameTime: Int) {
        self.gameCode = gameCode
        self.gameTime = gameTime
        self._remainingTime = State(initialValue: gameTime * 60)  // Convert minutes to seconds
    }

    var body: some View {
        VStack {
            Text("Game in Progress!")
                .font(.title)
                .padding(.bottom, 20)

            // Display the game code
            Text("Game Code: \(gameCode)")
                .font(.headline)
                .padding(.bottom, 20)

            // Display the countdown timer
            Text("Time Remaining: \(formattedTime(remainingTime))")
                .font(.largeTitle)
                .padding()

            Spacer()

            // Stop the timer when the view disappears
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()  // Stop the timer when leaving the view
        }
    }

    // Function to start the local countdown timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timer?.invalidate()
            }
        }
    }

    // Helper function to format the remaining time as MM:SS
    private func formattedTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


