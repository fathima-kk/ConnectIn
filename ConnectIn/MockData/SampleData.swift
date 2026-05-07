//
//  SampleData.swift
//  ConnectIn
//

import Foundation

/// Realistic mock content for previews and prototyping.
enum SampleData {

    // MARK: - Stable IDs

    private enum ID {
        static let student = UUID(uuidString: "10000000-0000-4000-8000-000000000001")!
        static let m1User = UUID(uuidString: "10000000-0000-4000-8000-000000000010")!
        static let m1 = UUID(uuidString: "10000000-0000-4000-8000-000000000011")!
        static let m2User = UUID(uuidString: "10000000-0000-4000-8000-000000000020")!
        static let m2 = UUID(uuidString: "10000000-0000-4000-8000-000000000021")!
        static let m3User = UUID(uuidString: "10000000-0000-4000-8000-000000000030")!
        static let m3 = UUID(uuidString: "10000000-0000-4000-8000-000000000031")!
        static let m4User = UUID(uuidString: "10000000-0000-4000-8000-000000000040")!
        static let m4 = UUID(uuidString: "10000000-0000-4000-8000-000000000041")!
        static let m5User = UUID(uuidString: "10000000-0000-4000-8000-000000000050")!
        static let m5 = UUID(uuidString: "10000000-0000-4000-8000-000000000051")!
        static let m6User = UUID(uuidString: "10000000-0000-4000-8000-000000000060")!
        static let m6 = UUID(uuidString: "10000000-0000-4000-8000-000000000061")!
        static let match1 = UUID(uuidString: "20000000-0000-4000-8000-000000000001")!
        static let match2 = UUID(uuidString: "20000000-0000-4000-8000-000000000002")!
        static let match3 = UUID(uuidString: "20000000-0000-4000-8000-000000000003")!
    }

    private static let baseDate = Date(timeIntervalSince1970: 1_720_000_000)

    // MARK: - Student

    static let student = User(
        id: ID.student,
        email: "smartinez1@mail.sfsu.edu",
        fullName: "Sofia Martinez",
        role: .student,
        profileImageURL: nil,
        bio: """
        I'm 20, a first-generation junior at San Francisco State. I'm drawn to where \
        tech and people meet—especially product management—and I'm trying to figure out \
        how to break in without a family network in the industry. I learn fast and \
        don't mind asking questions.
        """,
        interests: [
            "Product management",
            "Tech careers",
            "User research",
            "Roadmapping",
            "Internships",
        ],
        goals: [
            "Land a summer internship in tech",
            "Build a professional network I can lean on",
        ],
        university: "San Francisco State University",
        major: "Business Administration",
        graduationYear: 2027,
        isFirstGen: true,
        createdAt: baseDate
    )

    /// Logged-in profile; same as `student` for mock apps.
    static let currentUser = student

    // MARK: - Mentor user records (private)

    private static let marcusChenUser = User(
        id: ID.m1User,
        email: "mchen@email.com",
        fullName: "Marcus Chen",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        I grew up in Oakland and studied CS at UC Davis before landing in infra, then \
        product-facing backend teams. I remember how opaque hiring felt—I like helping \
        students demystify interviews and what hiring managers actually read on a resume.
        """,
        interests: ["Distributed systems", "Mentoring", "Interview prep"],
        goals: ["Pay it forward to Bay Area students"],
        university: "University of California, Davis",
        major: "Computer Science",
        graduationYear: 2015,
        isFirstGen: false,
        createdAt: baseDate
    )

    private static let priyaShahUser = User(
        id: ID.m2User,
        email: "priya.shah@pm.me",
        fullName: "Priya Shah",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        Former consultant who pivoted into PM. I've shipped B2B and growth products and \
        spent a lot of time with new grads navigating their first role. Happy to talk \
        discovery, metrics, and how to tell your story when you don't have internship XP yet.
        """,
        interests: ["Product strategy", "A/B testing", "Career pivots"],
        goals: ["Support women and first-gen folks in product"],
        university: "University of Michigan",
        major: "Economics",
        graduationYear: 2013,
        isFirstGen: false,
        createdAt: baseDate
    )

    private static let andreWashingtonUser = User(
        id: ID.m3User,
        email: "andre.w@folio.design",
        fullName: "André Washington",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        I lead design for a small team shipping mobile tools for freelancers. Before that \
        I was the first designer at two startups—I've seen scrappy and structured, and I \
        love helping students build a portfolio that reads as real work, not class projects.
        """,
        interests: ["Design systems", "Accessibility", "Portfolio reviews"],
        goals: ["Raise the bar for inclusive UX hiring"],
        university: "San José State University",
        major: "Graphic Design",
        graduationYear: 2016,
        isFirstGen: true,
        createdAt: baseDate
    )

    private static let elenaOkonkwoUser = User(
        id: ID.m4User,
        email: "e.okonkwo@nova-analytics.io",
        fullName: "Elena Okonkwo",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        I'm a data scientist at a Series B startup—lots of SQL, experimentation, and \
        translating messy questions into something measurable. I didn't know anyone in tech \
        when I started; I care a lot about helping students see data as a viable path even \
        if they aren't 'math olympiad' types.
        """,
        interests: ["SQL", "Causal inference", "Python", "Storytelling with data"],
        goals: ["Mentor students from non-traditional backgrounds"],
        university: "Howard University",
        major: "Mathematics",
        graduationYear: 2018,
        isFirstGen: false,
        createdAt: baseDate
    )

    private static let diegoMoralesUser = User(
        id: ID.m5User,
        email: "diego.morales.dev@gmail.com",
        fullName: "Diego Morales",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        Full-stack engineer at a fast-growing hiring-tech startup. I was a bootcamp grad \
        before my CS degree—I've done take-home assignments, live coding, and system design \
        on both sides of the table. I keep feedback honest and practical.
        """,
        interests: ["TypeScript", "System design", "Bootcamp to degree paths"],
        goals: ["Help more Latino students see themselves in eng"],
        university: "San Francisco State University",
        major: "Computer Science",
        graduationYear: 2019,
        isFirstGen: true,
        createdAt: baseDate
    )

    private static let meiTanUser = User(
        id: ID.m6User,
        email: "mei.tan@outlook.com",
        fullName: "Mei Tan",
        role: .mentor,
        profileImageURL: nil,
        bio: """
        Group PM covering consumer growth. I've hired interns and new grads and run \
        internship programs—happy to review how you frame impact, choose teams to apply to, \
        and prep for PM case-style conversations.
        """,
        interests: ["Growth loops", "Roadmaps", "Stakeholder management"],
        goals: ["Grow the next generation of thoughtful PMs"],
        university: "Carnegie Mellon University",
        major: "Information Systems",
        graduationYear: 2012,
        isFirstGen: false,
        createdAt: baseDate
    )

    // MARK: - Mentors

    static let mentors: [Mentor] = [
        Mentor(
            id: ID.m1,
            user: marcusChenUser,
            jobTitle: "Software Engineer",
            company: "Stripe",
            yearsExperience: 9,
            expertise: ["Backend", "System design", "Interview prep", "Python", "Go"],
            availability: "Tue & Thu evenings (PT), 30–45 min video",
            maxMentees: 3,
            currentMentees: 1,
            matchPercentage: 92
        ),
        Mentor(
            id: ID.m2,
            user: priyaShahUser,
            jobTitle: "Product Manager",
            company: "Figma",
            yearsExperience: 8,
            expertise: ["Product discovery", "Metrics", "Roadmaps", "B2B SaaS"],
            availability: "Saturday mornings or Sunday late afternoon (ET)",
            maxMentees: 4,
            currentMentees: 2,
            matchPercentage: 98
        ),
        Mentor(
            id: ID.m3,
            user: andreWashingtonUser,
            jobTitle: "UX Designer",
            company: "Folio Labs",
            yearsExperience: 6,
            expertise: ["UX research", "Figma", "Mobile UX", "Portfolio reviews"],
            availability: "Weekday lunch 12–1 PT, or async feedback on portfolios",
            maxMentees: 5,
            currentMentees: 2,
            matchPercentage: 84
        ),
        Mentor(
            id: ID.m4,
            user: elenaOkonkwoUser,
            jobTitle: "Data Scientist",
            company: "Nova Analytics",
            yearsExperience: 5,
            expertise: ["SQL", "Experimentation", "Python", "Analytics storytelling"],
            availability: "Mon/Wed 6–8pm ET",
            maxMentees: 3,
            currentMentees: 0,
            matchPercentage: 75
        ),
        Mentor(
            id: ID.m5,
            user: diegoMoralesUser,
            jobTitle: "Software Engineer",
            company: "Lattice",
            yearsExperience: 4,
            expertise: ["Full-stack", "TypeScript", "React", "Career switching"],
            availability: "Friday evenings or Sunday mornings (PT)",
            maxMentees: 4,
            currentMentees: 3,
            matchPercentage: 88
        ),
        Mentor(
            id: ID.m6,
            user: meiTanUser,
            jobTitle: "Product Manager",
            company: "Airbnb",
            yearsExperience: 11,
            expertise: ["Consumer product", "Growth", "A/B testing", "Intern hiring"],
            availability: "Biweekly Tue 5–7pm PT",
            maxMentees: 2,
            currentMentees: 1,
            matchPercentage: 95
        ),
    ]

    // MARK: - Compatibility phrases (reusable copy)

    static let compatibilityPhrases: [String] = [
        "Both interested in product management",
        "Shared first-gen background",
        "Same university alumni",
        "Matching career interests",
        "Overlapping goals around internships",
        "Both care about impact-driven product work",
        "Similar communication style in intro notes",
        "Mentor has hired interns in your target space",
    ]

    // MARK: - Sample matches (Sofia ↔ mentors)

    static let matches: [Match] = [
        Match(
            id: ID.match1,
            mentorId: ID.m2,
            studentId: ID.student,
            status: .pending,
            matchedAt: baseDate,
            compatibilityReasons: [
                "Both interested in product management",
                "Matching career interests",
                "Mentor has hired interns in your target space",
            ]
        ),
        Match(
            id: ID.match2,
            mentorId: ID.m5,
            studentId: ID.student,
            status: .accepted,
            matchedAt: baseDate,
            compatibilityReasons: [
                "Same university alumni",
                "Shared first-gen background",
                "Overlapping goals around internships",
            ]
        ),
        Match(
            id: ID.match3,
            mentorId: ID.m6,
            studentId: ID.student,
            status: .pending,
            matchedAt: baseDate,
            compatibilityReasons: [
                "Both interested in product management",
                "Matching career interests",
            ]
        ),
    ]
}
