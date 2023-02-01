//
//  ContentView.swift
//  sampleapp
//
//  Created by Leonardo Maia Pugliese on 27/01/2023.
//

import SwiftUI

// using ZStack to overlap the whole view with the Error View
//struct ContentView: View {
//    @ObservedObject var usersViewModel = UsersViewModel()
//
//    var body: some View {
//        ZStack {
//            List(usersViewModel.listUsers, id: \.self) { user in
//                Text(user)
//            }
//
//            if let error = usersViewModel.userError {
//                ErrorView(errorTitle: error.description, usersViewModel: usersViewModel)
//            }
//        }
//        .task {
//            try? await Task.sleep(for: .seconds(2))
//            await usersViewModel.loadUsers(withError: true)
//        }
//    }
//}
//
//struct ErrorView: View {
//    let errorTitle: String
//    @ObservedObject var usersViewModel: UsersViewModel
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 20)
//            .foregroundColor(.red)
//            .overlay {
//
//                VStack {
//                    Text(errorTitle)
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//
//                    Button("Reload Users") {
//                        Task {
//                            await usersViewModel.loadUsers(withError: false)
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//
//            }
//    }
//}

// -- -- - --  -- - - -- - - -

// Error handling with Alert
//struct ContentView: View {
//    @ObservedObject var usersViewModel = UsersViewModel()
//    @State var showAlert = false
//
//    var body: some View {
//        ZStack {
//            List(usersViewModel.listUsers, id: \.self) { user in
//                Text(user)
//            }
//        }
//        .task {
//            try? await Task.sleep(for: .seconds(2))
//            await usersViewModel.loadUsers(withError: true)
//        }
//        .onChange(of: usersViewModel.userError,
//                  perform: { newValue in
//            showAlert = newValue != nil
//        })
//        .alert(usersViewModel.userError?.description ?? "", isPresented: $showAlert) {
//            ErrorView(usersViewModel: usersViewModel)
//        }
//    }
//}
//
//struct ErrorView: View {
//    @ObservedObject var usersViewModel: UsersViewModel
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 20)
//            .foregroundColor(.red)
//            .overlay {
//
//                VStack {
//                    Button("Reload Users") {
//                        Task {
//                            await usersViewModel.loadUsers(withError: false)
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//
//            }
//    }
//}

// -- - --------------------------------------

// usando Custom toast view para mostrar no top
struct ContentView: View {
    @ObservedObject var usersViewModel = UsersViewModel()
    @State var showError = false

    var body: some View {
        VStack {
            List(usersViewModel.listUsers, id: \.self) { user in
                Text(user)
            }.overlay {
                if showError {
                    VStack {
                        ErrorView(errorTitle: usersViewModel.userError?.description ?? "", usersViewModel: usersViewModel)

                        Spacer()
                    }.transition(.move(edge: .top))
                }
            }.transition(.move(edge: .top))
        }
        .animation(.default, value: usersViewModel.userError)
        .task {
            try? await Task.sleep(for: .seconds(0.2))
            await usersViewModel.loadUsers(withError: true)
        }
        .onChange(of: usersViewModel.userError) { newValue in
            showError = newValue != nil
        }
    }
}

struct ErrorView: View {
    let errorTitle: String
    @ObservedObject var usersViewModel: UsersViewModel

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.red)
            .frame(height: 200)
            .padding()
            .overlay {

                VStack {
                    Text(errorTitle)
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    Button("Reload Users") {
                        Task {
                            await usersViewModel.loadUsers(withError: false)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

            }
    }
}

// --------------------------------------------------------------

class UsersViewModel: ObservableObject {
    @Published var listUsers = [String]()
    @Published var userError: UserError? = nil
    
    @MainActor
    func loadUsers(withError: Bool) async {
        if withError {
            userError = UserError.failedLoading
        } else {
            userError = nil
            listUsers = ["ninha", "Mike", "Pepijn"]
        }
    }
    
}

enum UserError: Error {
    case failedLoading
    
    var description: String {
        switch self {
        case .failedLoading:
            return "Sorry, we couldn't retrieve users. \n Try again later. ☹️"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
