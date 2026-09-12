import Foundation

/// The 7-day cycle taught by Vânia Sausen: one single text explored in depth
/// from Monday to Sunday, one skill/focus per day.
enum StudyDay: Int, CaseIterable, Codable, Identifiable, Hashable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .monday: return "Seg"
        case .tuesday: return "Ter"
        case .wednesday: return "Qua"
        case .thursday: return "Qui"
        case .friday: return "Sex"
        case .saturday: return "Sáb"
        case .sunday: return "Dom"
        }
    }

    var title: String {
        switch self {
        case .monday: return "Leitura e Interpretação"
        case .tuesday: return "Collocations"
        case .wednesday: return "Listening & Shadowing"
        case .thursday: return "Gramática em Contexto"
        case .friday: return "Produção Escrita"
        case .saturday: return "Prática de Fala"
        case .sunday: return "Revisão Ativa"
        }
    }

    var subtitle: String {
        switch self {
        case .monday: return "Entenda o texto e anote 5 chunks novos"
        case .tuesday: return "Descubra com quais palavras seus chunks combinam"
        case .wednesday: return "Ouça e repita imitando ritmo e entonação"
        case .thursday: return "Veja a gramática escondida no texto"
        case .friday: return "Escreva sobre a sua própria rotina"
        case .saturday: return "Leia em voz alta e grave sua pronúncia"
        case .sunday: return "Feche o material e tente lembrar tudo"
        }
    }

    /// SF Symbol used across the UI for this day's mission.
    var symbolName: String {
        switch self {
        case .monday: return "book.fill"
        case .tuesday: return "link"
        case .wednesday: return "headphones"
        case .thursday: return "text.book.closed.fill"
        case .friday: return "pencil.line"
        case .saturday: return "mic.fill"
        case .sunday: return "brain.head.profile"
        }
    }

    /// XP awarded for completing this day's mission.
    var xpReward: Int {
        switch self {
        case .sunday: return 25
        default: return 15
        }
    }
}
