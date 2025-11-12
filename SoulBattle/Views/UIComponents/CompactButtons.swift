import SwiftUI

struct CompactAttackButton: View {
    let attackType: AttackType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: attackType.icon)
                    .font(.system(size: 12))
                Text(attackType.rawValue)
                    .font(.system(size: 10))
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                }
            }
            .padding(6)
            .background(isSelected ? Color.red.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .red : .primary)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.red : Color.gray, lineWidth: 1)
            )
        }
    }
}

struct CompactDefenseButton: View {
    let defenseType: DefenseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: defenseType.icon)
                    .font(.system(size: 12))
                Text(defenseType.rawValue)
                    .font(.system(size: 10))
                    .lineLimit(1)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                }
            }
            .padding(6)
            .background(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}
