import Foundation

enum AttackType: String, CaseIterable, Identifiable {
    case fire = "Огненная атака"
    case lightning = "Атака молнией"
    case weapon = "Атака оружием"
    case acid = "Кислотная атака"
    case psycho = "Психо-атака"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fire: return "flame"
        case .lightning: return "bolt"
        case .weapon: return "hammer"
        case .acid: return "drop"
        case .psycho: return "brain.head.profile"
        }
    }
}

enum DefenseType: String, CaseIterable, Identifiable {
    case fire = "Защита от огня"
    case lightning = "Защита от молнии"
    case weapon = "Защита от оружия"
    case acid = "Защита от кислоты"
    case psycho = "Психо-защита"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fire: return "flame"
        case .lightning: return "bolt"
        case .weapon: return "shield"
        case .acid: return "drop"
        case .psycho: return "brain.head.profile"
        }
    }
}
