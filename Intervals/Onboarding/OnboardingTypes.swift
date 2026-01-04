//
//  OnboardingTypes.swift
//  Intervals
//

import Foundation

// MARK: - Age Groups

enum AgeGroup: String, Codable, CaseIterable {
    case age4to6 = "4-6"
    case age7to9 = "7-9"
    case age10to12 = "10-12"
    case age13to15 = "13-15"
    case age16to18 = "16-18"

    var displayLabel: String {
        switch self {
        case .age4to6: return "4, 5, or 6"
        case .age7to9: return "7, 8, or 9"
        case .age10to12: return "10, 11, or 12"
        case .age13to15: return "13, 14, or 15"
        case .age16to18: return "16, 17, or 18"
        }
    }

    var icon: String {
        switch self {
        case .age4to6: return "figure.child"
        case .age7to9: return "figure.wave"
        case .age10to12: return "backpack.fill"
        case .age13to15: return "headphones"
        case .age16to18: return "graduationcap.fill"
        }
    }

    var uiComplexity: UIComplexity {
        switch self {
        case .age4to6: return .simplified
        case .age7to9, .age10to12: return .standard
        case .age13to15, .age16to18: return .mature
        }
    }
}

enum UIComplexity: String, Codable {
    case simplified  // Larger elements, more animations, simpler language
    case standard    // Normal child-friendly UI
    case mature      // Reduced "cutesy" elements, streamlined
}

// MARK: - Setup Flow

enum SetupFlow: String, Codable {
    case child
    case parent

    var welcomeHeadline: String {
        switch self {
        case .child: return "Hi there! I'm Tempo!"
        case .parent: return "Welcome to Intervals"
        }
    }

    var welcomeSubtext: String {
        switch self {
        case .child: return "I'm going to help you become an ear training superstar!"
        case .parent: return "Let's set up a personalized learning experience for your child."
        }
    }

    var ctaText: String {
        switch self {
        case .child: return "Let's go!"
        case .parent: return "Get Started"
        }
    }

    var continueText: String {
        switch self {
        case .child: return "Next"
        case .parent: return "Continue"
        }
    }
}

// MARK: - Learning Goals

enum LearningGoal: String, Codable, CaseIterable {
    case examPrep = "exam_prep"
    case improvingEar = "improving_ear"
    case teacherRecommended = "teacher_recommended"
    case justForFun = "just_for_fun"

    var displayLabel: String {
        switch self {
        case .examPrep: return "Preparing for an exam"
        case .improvingEar: return "Improving my musical ear"
        case .teacherRecommended: return "My teacher recommended this"
        case .justForFun: return "Just for fun!"
        }
    }

    var icon: String {
        switch self {
        case .examPrep: return "doc.text.fill"
        case .improvingEar: return "ear.fill"
        case .teacherRecommended: return "person.fill.viewfinder"
        case .justForFun: return "gamecontroller.fill"
        }
    }
}

// MARK: - Onboarding Instrument

enum OnboardingInstrument: String, Codable, CaseIterable {
    case piano
    case violin
    case voice
    case guitar
    case flute
    case clarinet
    case trumpet
    case cello
    case drums
    case other

    var displayLabel: String {
        switch self {
        case .piano: return "Piano"
        case .violin: return "Violin"
        case .voice: return "Voice/Singing"
        case .guitar: return "Guitar"
        case .flute: return "Flute"
        case .clarinet: return "Clarinet"
        case .trumpet: return "Trumpet"
        case .cello: return "Cello"
        case .drums: return "Drums/Percussion"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .piano: return "pianokeys"
        case .violin, .cello: return "guitars.fill"
        case .voice: return "mic.fill"
        case .guitar: return "guitars"
        case .flute: return "wind"
        case .clarinet: return "music.note"
        case .trumpet: return "horn.fill"
        case .drums: return "drum.fill"
        case .other: return "plus.circle.fill"
        }
    }
}

// MARK: - ABRSM Grade (for onboarding)

enum ABRSMGrade: Int, Codable, CaseIterable {
    case preGrade1 = 0
    case grade1 = 1
    case grade2 = 2
    case grade3 = 3
    case grade4 = 4
    case grade5 = 5
    case grade6 = 6
    case grade7 = 7
    case grade8 = 8
    case notSure = -1

    var displayName: String {
        switch self {
        case .preGrade1: return "Just starting out"
        case .notSure: return "I'm not sure"
        default: return "Grade \(rawValue)"
        }
    }

    /// Convert to app's Grade enum
    var toGrade: Grade {
        switch self {
        case .preGrade1, .grade1, .notSure: return .initial
        case .grade2: return .grade2
        case .grade3: return .grade3
        case .grade4: return .grade4
        case .grade5: return .grade5
        case .grade6: return .grade6
        case .grade7: return .grade7
        case .grade8: return .grade8
        }
    }
}

// MARK: - Onboarding Screen

enum OnboardingScreen: Int, CaseIterable {
    case flowSelection = 0
    case welcome = 1
    case nameInput = 2
    case ageSelection = 3
    case instrumentSelection = 4
    case gradeSelection = 5
    case goalSelection = 6
    case reminderSetup = 7
    case completion = 8

    var title: String {
        switch self {
        case .flowSelection: return "Welcome"
        case .welcome: return "Welcome"
        case .nameInput: return "Your Name"
        case .ageSelection: return "Your Age"
        case .instrumentSelection: return "Instruments"
        case .gradeSelection: return "Grade Level"
        case .goalSelection: return "Your Goal"
        case .reminderSetup: return "Reminders"
        case .completion: return "All Set!"
        }
    }

    static var totalScreens: Int {
        Self.allCases.count
    }
}

// MARK: - Weekday

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var initial: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }

    static var weekdays: [Weekday] {
        [.monday, .tuesday, .wednesday, .thursday, .friday]
    }
}

// MARK: - Onboarding Defaults

struct OnboardingDefaults {
    static let name = "Friend"
    static let ageGroup: AgeGroup = .age7to9
    static let instrument: OnboardingInstrument = .piano
    static let grade: ABRSMGrade = .grade1
    static let goal: LearningGoal = .improvingEar
    static let reminderEnabled = false
    static let reminderTime: Date = {
        var components = DateComponents()
        components.hour = 16  // 4:00 PM
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    static let reminderDays: [Weekday] = Weekday.weekdays
}
