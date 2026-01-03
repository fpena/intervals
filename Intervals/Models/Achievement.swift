//
//  Achievement.swift
//  Intervals
//

import Foundation

enum Achievement: String, CaseIterable, Identifiable {
    // Streak achievements
    case firstDay = "first_day"
    case weekStreak = "week_streak"
    case monthStreak = "month_streak"
    case hundredDayStreak = "hundred_day_streak"

    // Exercise count achievements
    case first10Exercises = "first_10"
    case first100Exercises = "first_100"
    case first1000Exercises = "first_1000"

    // Accuracy achievements
    case perfectSession = "perfect_session"    // 100% in a session of 10+
    case sharpEar = "sharp_ear"                // 90%+ accuracy over 100 exercises

    // Grade progression
    case completeInitial = "complete_initial"
    case completeGrade1 = "complete_grade1"
    case completeGrade2 = "complete_grade2"
    case completeGrade3 = "complete_grade3"
    case completeGrade4 = "complete_grade4"
    case completeGrade5 = "complete_grade5"
    case completeGrade6 = "complete_grade6"
    case completeGrade7 = "complete_grade7"
    case completeGrade8 = "complete_grade8"

    // Exercise type mastery
    case intervalMaster = "interval_master"
    case chordMaster = "chord_master"
    case rhythmMaster = "rhythm_master"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstDay: return "First Steps"
        case .weekStreak: return "Week Warrior"
        case .monthStreak: return "Monthly Master"
        case .hundredDayStreak: return "Century Club"
        case .first10Exercises: return "Getting Started"
        case .first100Exercises: return "Dedicated Learner"
        case .first1000Exercises: return "Practice Pro"
        case .perfectSession: return "Perfect Pitch"
        case .sharpEar: return "Sharp Ear"
        case .completeInitial: return "Initial Complete"
        case .completeGrade1: return "Grade 1 Complete"
        case .completeGrade2: return "Grade 2 Complete"
        case .completeGrade3: return "Grade 3 Complete"
        case .completeGrade4: return "Grade 4 Complete"
        case .completeGrade5: return "Grade 5 Complete"
        case .completeGrade6: return "Grade 6 Complete"
        case .completeGrade7: return "Grade 7 Complete"
        case .completeGrade8: return "Grade 8 Complete"
        case .intervalMaster: return "Interval Master"
        case .chordMaster: return "Chord Master"
        case .rhythmMaster: return "Rhythm Master"
        }
    }

    var description: String {
        switch self {
        case .firstDay: return "Complete your first day of practice"
        case .weekStreak: return "Practice 7 days in a row"
        case .monthStreak: return "Practice 30 days in a row"
        case .hundredDayStreak: return "Practice 100 days in a row"
        case .first10Exercises: return "Complete 10 exercises"
        case .first100Exercises: return "Complete 100 exercises"
        case .first1000Exercises: return "Complete 1,000 exercises"
        case .perfectSession: return "Get 100% accuracy in a session of 10+ exercises"
        case .sharpEar: return "Maintain 90%+ accuracy over 100 exercises"
        case .completeInitial: return "Master all Initial grade exercises"
        case .completeGrade1: return "Master all Grade 1 exercises"
        case .completeGrade2: return "Master all Grade 2 exercises"
        case .completeGrade3: return "Master all Grade 3 exercises"
        case .completeGrade4: return "Master all Grade 4 exercises"
        case .completeGrade5: return "Master all Grade 5 exercises"
        case .completeGrade6: return "Master all Grade 6 exercises"
        case .completeGrade7: return "Master all Grade 7 exercises"
        case .completeGrade8: return "Master all Grade 8 exercises"
        case .intervalMaster: return "Reach 90%+ accuracy on all interval types"
        case .chordMaster: return "Reach 90%+ accuracy on all chord types"
        case .rhythmMaster: return "Reach 90%+ accuracy on rhythm exercises"
        }
    }

    var iconName: String {  // SF Symbol name
        switch self {
        case .firstDay: return "star.fill"
        case .weekStreak, .monthStreak, .hundredDayStreak: return "flame.fill"
        case .first10Exercises, .first100Exercises, .first1000Exercises: return "checkmark.circle.fill"
        case .perfectSession, .sharpEar: return "ear.fill"
        case .completeInitial, .completeGrade1, .completeGrade2, .completeGrade3,
             .completeGrade4, .completeGrade5, .completeGrade6, .completeGrade7,
             .completeGrade8: return "graduationcap.fill"
        case .intervalMaster, .chordMaster, .rhythmMaster: return "trophy.fill"
        }
    }

    var xpReward: Int {
        switch self {
        case .firstDay: return 10
        case .weekStreak: return 50
        case .monthStreak: return 200
        case .hundredDayStreak: return 1000
        case .first10Exercises: return 20
        case .first100Exercises: return 100
        case .first1000Exercises: return 500
        case .perfectSession: return 50
        case .sharpEar: return 200
        case .completeInitial: return 100
        case .completeGrade1, .completeGrade2, .completeGrade3: return 150
        case .completeGrade4, .completeGrade5: return 200
        case .completeGrade6, .completeGrade7, .completeGrade8: return 300
        case .intervalMaster, .chordMaster, .rhythmMaster: return 250
        }
    }
}
