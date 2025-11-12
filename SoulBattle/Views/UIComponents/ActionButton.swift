import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var backgroundColor: Color = .blue
    var size: ButtonSize = .medium
    
    enum ButtonSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .subheadline
            case .medium: return .headline
            case .large: return .title3
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 15
            case .large: return 18
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .small: return 3
            case .medium: return 5
            case .large: return 8
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(.white)
                .padding(.vertical, size.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isEnabled ? [backgroundColor, .purple] : [.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(size.cornerRadius)
                .shadow(radius: isEnabled ? size.shadowRadius : 0)
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
    }
}
