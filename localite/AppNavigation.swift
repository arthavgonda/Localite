import SwiftUI
import Combine

final class AppNavigation: ObservableObject {
    @Published var selectedProduct: Product?
    @Published var selectedSourceID: String?
}

private struct HeroNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var heroNamespace: Namespace.ID? {
        get { self[HeroNamespaceKey.self] }
        set { self[HeroNamespaceKey.self] = newValue }
    }
}

extension View {
    @ViewBuilder
    func matchedGeometryEffectIfAvailable(id: String, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            self.matchedGeometryEffect(id: id, in: namespace)
        } else {
            self
        }
    }
}
