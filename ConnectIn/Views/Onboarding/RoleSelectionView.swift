//
//  RoleSelectionView.swift
//  ConnectIn
//

import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        List(UserRole.allCases, id: \.self) { role in
            NavigationLink(value: role) {
                Text(role.rawValue.capitalized)
            }
        }
        .navigationTitle("I am a…")
        .navigationDestination(for: UserRole.self) { _ in
            ProfileCreationView()
        }
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView()
    }
}
