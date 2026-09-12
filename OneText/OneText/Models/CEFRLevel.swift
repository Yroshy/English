import Foundation

/// The six CEFR (Common European Framework of Reference) proficiency levels.
enum CEFRLevel: String, CaseIterable, Codable, Identifiable, Comparable, Hashable {
    case a1, a2, b1, b2, c1, c2

    var id: String { rawValue }

    var displayName: String { rawValue.uppercased() }

    var title: String {
        switch self {
        case .a1: return "Iniciante"
        case .a2: return "Básico"
        case .b1: return "Intermediário"
        case .b2: return "Intermediário Superior"
        case .c1: return "Avançado"
        case .c2: return "Proficiente"
        }
    }

    var description: String {
        switch self {
        case .a1: return "Frases simples do dia a dia, vocabulário essencial."
        case .a2: return "Rotinas, descrições curtas, necessidades imediatas."
        case .b1: return "Textos conectados sobre trabalho, viagens e o cotidiano."
        case .b2: return "Textos mais longos, opiniões e argumentos claros."
        case .c1: return "Textos complexos, nuances e vocabulário variado."
        case .c2: return "Fluência quase nativa, textos ricos e idiomáticos."
        }
    }

    /// Guides the AI generator on how long and how complex a weekly text should be.
    var wordCountRange: ClosedRange<Int> {
        switch self {
        case .a1: return 40...70
        case .a2: return 60...100
        case .b1: return 90...140
        case .b2: return 120...180
        case .c1: return 150...220
        case .c2: return 180...260
        }
    }

    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        let order = CEFRLevel.allCases
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

/// Everyday routine topics — the initial focus requested: short texts with real,
/// day-to-day use of English (not abstract or literary topics).
enum RoutineTopic: String, CaseIterable, Codable, Identifiable, Hashable {
    case morningRoutine
    case commuteToWork
    case workDay
    case groceryShopping
    case cookingDinner
    case weekendPlans
    case gymRoutine
    case gettingKidsReady
    case eveningWindDown
    case houseChores

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .morningRoutine: return "Rotina da manhã"
        case .commuteToWork: return "Indo para o trabalho"
        case .workDay: return "Um dia de trabalho"
        case .groceryShopping: return "Compras no mercado"
        case .cookingDinner: return "Preparando o jantar"
        case .weekendPlans: return "Planos de fim de semana"
        case .gymRoutine: return "Rotina na academia"
        case .gettingKidsReady: return "Preparando as crianças"
        case .eveningWindDown: return "Relaxando à noite"
        case .houseChores: return "Tarefas de casa"
        }
    }
}
