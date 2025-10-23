//
//  SwiftDataWorkoutSessionStore.swift
//  WorkoutTrack
//
//  Created by Min-Yang Huang on 2025/10/17.
//

import Foundation
import SwiftData

@ModelActor
final actor SwiftDataWorkoutSessionStore {
    
    func retrieve(query: SessionQueryDescriptor?) throws -> [WorkoutSessionDTO] {
        var descriptor = FetchDescriptor<WorkoutSession>()
        let (predicate, sort, _) = translate(query)
        if let predicate {
            descriptor.predicate = predicate
        }
        if !sort.isEmpty {
            descriptor.sortBy = sort
        }
        return try modelContext.fetch(descriptor).map(\.dto)
    }
    
    func insert(_ session: WorkoutSessionDTO) throws {
        if let existing = try getSessionFromContext(id: session.id) {
            existing.update(from: session, in: modelContext)
        } else {
            let model = WorkoutSession(dto: session)
            modelContext.insert(model)
        }
        
        try modelContext.save()
    }
    
    func insert(_ entries: [WorkoutEntryDTO], to session: WorkoutSessionDTO) throws {
        guard let existing = try getSessionFromContext(id: session.id) else {
            try insert(session)
            try insert(entries, to: session)
            return
        }
        entries.forEach { insert($0, in: existing) }
        try modelContext.save()
    }
    
    func delete(_ session: WorkoutSessionDTO) throws {
        guard let existing = try getSessionFromContext(id: session.id) else { return }
        
        modelContext.delete(existing)
        try modelContext.save()
    }
}

extension SwiftDataWorkoutSessionStore {
    private func getSessionFromContext(id: UUID) throws -> WorkoutSession? {
        let descriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
    
    private func insert(_ entryDTO: WorkoutEntryDTO, in session: WorkoutSession) {
        let entry = WorkoutEntry(dto: entryDTO)
        entry.session = session
        modelContext.insert(entry)
    }
    
    private func translate(_ query: SessionQueryDescriptor?) -> (Predicate<WorkoutSession>?, [SortDescriptor<WorkoutSession>], Any?) {
        guard let query else { return (nil, [], nil) }
        let predicate = PredicateFactory.getPredicate(query.sessionId, query.dateRange, query.containExercises)
        let sortDescriptor = getSortDescriptor(query.sortBy)
        
        return (predicate, sortDescriptor, nil)
    }
    
    private func getSortDescriptor(_ arr: [QuerySort]?) -> [SortDescriptor<WorkoutSession>] {
        guard let arr else { return [] }
        var sortDescriptor: [SortDescriptor<WorkoutSession>] = []
        for sort in arr {
            switch sort {
            case .byId(let ascending):
                sortDescriptor.append(SortDescriptor(\.id, order: ascending ? .forward : .reverse))
            case .byDate(let ascending):
                sortDescriptor.append(SortDescriptor(\.date, order: ascending ? .forward : .reverse))
            }
        }
        return sortDescriptor
    }
}

struct PredicateFactory {
    static func getPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercise: [UUID]?) -> Predicate<WorkoutSession> {
        if #available(macOS 14.4, iOS 17.4, *) {
            return newPredicate(id, date, exercise)
        } else {
            return legacyPredicate(id, date, exercise)
        }
    }
    
    @available(macOS 14.4, iOS 17.4, *)
    private static func newPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercise: [UUID]?) -> Predicate<WorkoutSession> {
        var idPredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        var datePredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        var exercisePredicate: Predicate<WorkoutSession> = #Predicate { _ in true }
        
        if let id {
            idPredicate = #Predicate { $0.id == id }
        }
        
        if let date {
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            
            datePredicate = #Predicate {
                (lowerbound...upperbound).contains($0.date)
            }
        }
        
        if let exercise {
            exercisePredicate = #Predicate {
                $0.entries.contains(where: { entry in exercise.contains(entry.exerciseID) })
            }
        }
        
        return #Predicate<WorkoutSession> { session in
            idPredicate.evaluate(session) && datePredicate.evaluate(session) && exercisePredicate.evaluate(session)
        }
    }
    
    private static func legacyPredicate(_ id: UUID?, _ date: ClosedRange<Date>?, _ exercises: [UUID]?) -> Predicate<WorkoutSession> {
        switch (id, date, exercises) {
        case (let id?, nil, nil):
            return #Predicate { $0.id == id }
        case let (nil, date?, nil):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { (lowerbound...upperbound).contains($0.date) }
        case (let id?, let date?, nil):
            let lowerbound = date.lowerBound.startOfDay()
            let upperbound = date.upperBound.endOfDay()
            return #Predicate { $0.id == id && (lowerbound...upperbound).contains($0.date) }
        case (nil, nil, let exercises?):
            return #Predicate {
                $0.entries.contains(where: { entry in exercises.contains(entry.exerciseID) })
            }
        default:
            return #Predicate { _ in true }
        }
    }
}


extension WorkoutSession {
    func update(from dto: WorkoutSessionDTO, in context: ModelContext) {
        self.date = dto.date
        entries.forEach { context.delete($0) }
        
        self.entries = dto.entries.map { entryDTO in
            let entry = WorkoutEntry(dto: entryDTO)
            entry.session = self
            return entry
        }
    }
}

extension Date {
    func startOfDay(using calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    func endOfDay(using calendar: Calendar = .current) -> Date {
        let start = startOfDay(using: calendar)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start)!
    }
}
