import Foundation

class BattleSystem {
    
    // Модификаторы урона для каждого типа атаки
    private let attackModifiers: [AttackType: (strength: Double, agility: Double, wisdom: Double, intellect: Double)] = [
        .fire: (0.2, 0.1, 0.4, 0.3),
        .lightning: (0.1, 0.3, 0.3, 0.3),
        .weapon: (0.5, 0.3, 0.1, 0.1),
        .acid: (0.2, 0.2, 0.3, 0.3),
        .psycho: (0.1, 0.1, 0.4, 0.4)
    ]
    
    // Эффективность защит
    private let defenseEffectiveness: [DefenseType: [AttackType: Double]] = [
        .fire: [.fire: 0.8, .lightning: 0.2, .weapon: 0.1, .acid: 0.3, .psycho: 0.1],
        .lightning: [.fire: 0.2, .lightning: 0.8, .weapon: 0.1, .acid: 0.2, .psycho: 0.3],
        .weapon: [.fire: 0.1, .lightning: 0.1, .weapon: 0.8, .acid: 0.4, .psycho: 0.1],
        .acid: [.fire: 0.3, .lightning: 0.2, .weapon: 0.4, .acid: 0.8, .psycho: 0.2],
        .psycho: [.fire: 0.1, .lightning: 0.3, .weapon: 0.1, .acid: 0.2, .psycho: 0.8]
    ]
    
    func calculateDamage(attacker: Player, defender: Player) -> Double {
        var totalDamage: Double = 0
        
        for attack in attacker.selectedAttacks {
            let baseDamage = calculateBaseDamage(for: attack, player: attacker)
            let defenseReduction = calculateDefenseReduction(attack: attack, defender: defender)
            let finalDamage = max(baseDamage * (1.0 - defenseReduction), 0)
            totalDamage += finalDamage
            
            print("\(attacker.name) использует \(attack.rawValue): \(String(format: "%.1f", finalDamage)) урона")
        }
        
        return totalDamage
    }
    
    private func calculateBaseDamage(for attack: AttackType, player: Player) -> Double {
        guard let modifiers = attackModifiers[attack] else { return 0 }
        
        let baseDamage = 10.0
        let statBonus = Double(player.strength) * modifiers.strength +
                       Double(player.agility) * modifiers.agility +
                       Double(player.wisdom) * modifiers.wisdom +
                       Double(player.intellect) * modifiers.intellect
        
        return baseDamage + statBonus * 0.5
    }
    
    private func calculateDefenseReduction(attack: AttackType, defender: Player) -> Double {
        var totalReduction: Double = 0
        
        // Базовая защита от выносливости
        let enduranceReduction = Double(defender.endurance) * 0.02
        totalReduction += enduranceReduction
        
        // Выбранные защиты
        for defense in defender.selectedDefenses {
            if let effectiveness = defenseEffectiveness[defense]?[attack] {
                totalReduction += effectiveness * 0.3
            }
        }
        
        // Уклонение от ловкости
        let dodgeChance = Double(defender.agility) * 0.01
        if Double.random(in: 0...1) < dodgeChance {
            print("\(defender.name) уклонился от атаки!")
            totalReduction += 0.5
        }
        
        return min(totalReduction, 0.8)
    }
}
