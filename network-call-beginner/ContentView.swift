//
//  ContentView.swift
//  network-call-beginner
//
//  Created by anhduc on 11/24/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)

            Text(user?.login ?? "User placeholder")
                .font(.title3)
                .bold()
            
            Text(user?.bio ?? "Bio placeholder")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch CustomError.invalidURL {
                print("Invalid URL")
            } catch CustomError.invalidResponse {
                print("Invalid Response")
            } catch CustomError.invalidData {
                print("Invalid Data")
            } catch {
                print("Invalid Error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "http://api.github.com/users/dynamite-tnt-1"
        
        guard let url = URL(string: endpoint) else { throw CustomError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CustomError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw CustomError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum CustomError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
