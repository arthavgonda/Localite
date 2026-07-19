import SwiftUI
import Combine

final class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()

    private init() {
        memoryCache.countLimit = 300
        memoryCache.totalCostLimit = 150 * 1024 * 1024
    }

    func image(for key: String) -> UIImage? {
        memoryCache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func removeAll() {
        memoryCache.removeAllObjects()
    }
}

enum ImageDownloader {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 30 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024,
            diskPath: "localite-image-cache"
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.httpMaximumConnectionsPerHost = 6
        return URLSession(configuration: config)
    }()
}

enum ImageLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var state: ImageLoadState = .idle

    private var currentURL: URL?
    private var task: Task<Void, Never>?

    func load(url: URL?) {
        guard let url else {
            cancel()
            image = nil
            state = .idle
            currentURL = nil
            return
        }

        if url == currentURL, image != nil || state == .loading {
            return
        }

        currentURL = url
        task?.cancel()

        let key = url.absoluteString
        if let cached = ImageCache.shared.image(for: key) {
            image = cached
            state = .loaded
            return
        }

        image = nil
        state = .loading

        task = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                let (data, response) = try await ImageDownloader.session.data(from: url)
                try Task.checkCancellation()

                guard
                    let httpResponse = response as? HTTPURLResponse,
                    (200..<300).contains(httpResponse.statusCode),
                    let downloaded = UIImage(data: data)
                else {
                    await self.markFailed(for: url)
                    return
                }

                let decoded = Self.decoded(downloaded)
                try Task.checkCancellation()

                await ImageCache.shared.insert(decoded, for: key)
                await self.markLoaded(decoded, for: url)
            } catch is CancellationError {
            } catch {
                await self.markFailed(for: url)
            }
        }
    }

    private nonisolated static func decoded(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(at: .zero)
        }
    }

    @MainActor
    private func markLoaded(_ image: UIImage, for url: URL) {
        guard currentURL == url else { return }
        self.image = image
        state = .loaded
    }

    @MainActor
    private func markFailed(for url: URL) {
        guard currentURL == url else { return }
        state = .failed
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
