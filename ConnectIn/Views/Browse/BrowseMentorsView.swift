//
//  BrowseMentorsView.swift
//  ConnectIn
//

import SwiftUI
import UIKit

struct BrowseMentorsView: View {
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case highestMatch = "Highest Match"
        case availableNow = "Available Now"

        var id: Self { self }

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .highestMatch: return "star.fill"
            case .availableNow: return "clock.fill"
            }
        }
    }

    @EnvironmentObject private var connectionsManager: ConnectionsManager

    @State private var searchText: String = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var mentors: [Mentor] = SampleData.mentors
    @State private var showsAdvancedFilters: Bool = false
    @State private var refreshTick: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchBar
                filterChips

                if filteredMentors.isEmpty {
                    emptyState
                        .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredMentors) { mentor in
                            NavigationLink(value: mentor) {
                                MentorCard(
                                    mentor: mentor,
                                    connectionStatus: connectionsManager.status(for: mentor)
                                ) {}
                                .allowsHitTesting(false)
                            }
                            .buttonStyle(MentorCardLinkStyle())
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    .animation(.easeInOut(duration: 0.25), value: filteredMentors)
                }
            }
            .padding(.top, 8)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .refreshable {
            await refresh()
        }
        .sensoryFeedback(.success, trigger: refreshTick)
        .navigationTitle("Find Mentors")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showsAdvancedFilters) {
            advancedFiltersSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Sections

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.Colors.textSecondary)
            TextField("Search by name, company, or skill", text: $searchText)
                .connectInBody()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button {
                    withAnimation { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.cardBackground, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.Colors.divider, lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterOption.allCases) { option in
                    FilterChip(
                        title: option.rawValue,
                        icon: option.icon,
                        isSelected: selectedFilter == option
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
                            selectedFilter = option
                        }
                    }
                }

                Button {
                    showsAdvancedFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary)
                        .padding(10)
                        .background(AppTheme.Colors.cardBackground, in: Circle())
                        .overlay { Circle().strokeBorder(AppTheme.Colors.divider, lineWidth: 1) }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.Colors.secondary)
            Text("No mentors found")
                .connectInHeadline()
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Try adjusting your filters or clearing your search.")
                .connectInBody()
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            if !searchText.isEmpty || selectedFilter != .all {
                Button {
                    withAnimation {
                        searchText = ""
                        selectedFilter = .all
                    }
                } label: {
                    Text("Clear Filters")
                        .connectInBody()
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.cardBackground)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(AppTheme.Colors.accent, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .transition(.opacity.combined(with: .offset(y: 8)))
    }

    private var advancedFiltersSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("More filters coming soon — like industry, years of experience, and time-zone alignment.")
                    .connectInBody()
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Spacer()
                PrimaryButton(title: "Done", style: .primary, isLoading: false) {
                    showsAdvancedFilters = false
                }
            }
            .padding(20)
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Filtering

    private var filteredMentors: [Mentor] {
        var result = mentors

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let needle = trimmed.lowercased()
            result = result.filter { mentor in
                mentor.user.fullName.lowercased().contains(needle) ||
                    mentor.company.lowercased().contains(needle) ||
                    mentor.jobTitle.lowercased().contains(needle) ||
                    mentor.expertise.contains { $0.lowercased().contains(needle) }
            }
        }

        switch selectedFilter {
        case .all:
            break
        case .highestMatch:
            result.sort { $0.matchPercentage > $1.matchPercentage }
        case .availableNow:
            result = result.filter { $0.currentMentees < $0.maxMentees }
        }
        return result
    }

    private func refresh() async {
        try? await Task.sleep(for: .seconds(0.8))
        mentors = SampleData.mentors.shuffled()
        refreshTick += 1
    }
}

// MARK: - Subviews

private struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .connectInCaption()
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? AppTheme.Colors.cardBackground : AppTheme.Colors.textPrimary)
            .background(
                Capsule().fill(isSelected ? AppTheme.Colors.accent : AppTheme.Colors.cardBackground)
            )
            .overlay {
                Capsule().strokeBorder(
                    isSelected ? AppTheme.Colors.accent : AppTheme.Colors.divider,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

private struct MentorCardLinkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        BrowseMentorsView()
            .navigationDestination(for: Mentor.self) { mentor in
                MentorDetailView(mentor: mentor)
            }
    }
    .environmentObject(ConnectionsManager(persisted: false))
}
