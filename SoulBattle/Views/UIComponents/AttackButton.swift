import SwiftUI

struct AttackButton: View {
    let attackType: AttackType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: attackType.icon)
                Text(attackType.rawValue)
                    .font(.caption)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .background(isSelected ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .red : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.red : Color.gray, lineWidth: 1)
            )
        }
    }
}
