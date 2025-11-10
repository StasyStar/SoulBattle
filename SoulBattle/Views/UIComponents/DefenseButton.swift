import SwiftUI

struct DefenseButton: View {
    let defenseType: DefenseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            print("DefenseButton нажата: \(defenseType.rawValue)")
            action()
        }) {
            HStack {
                Image(systemName: defenseType.icon)
                Text(defenseType.rawValue)
                    .font(.caption)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}
