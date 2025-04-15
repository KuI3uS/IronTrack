import SwiftUI

#if os(iOS)
import UIKit

typealias KeyboardType = UIKeyboardType

extension View {
    func keyboardTypeCompat(_ type: KeyboardType) -> some View {
        self.keyboardType(type)
    }
}
#else
// macOS – bez fizycznej klawiatury ekranowej, zwracamy widok bez zmian
enum KeyboardType {
    case `default`
    case numberPad
}

extension View {
    func keyboardTypeCompat(_ type: KeyboardType) -> some View {
        self
    }
}
#endif
