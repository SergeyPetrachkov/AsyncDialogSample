import UIKit

public struct AsyncDialog {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

public protocol DialogAction {
  var title: String { get }
  var isDangerous: Bool { get }
  var action: (() -> Void)? { get }
}

public struct DefaultDialogAction: DialogAction {
  public let title: String
  public let isDangerous: Bool
  public let action: (() -> Void)?

  public init(title: String, isDangerous: Bool = false, action: (() -> Void)? = nil) {
    self.title = title
    self.isDangerous = isDangerous
    self.action = action
  }

  public static func cancel() -> DialogAction {
    return DefaultDialogAction(title: "Cancel")
  }
}

public struct AsyncDialogConfigurator {
  public let title: String?
  public let message: String?
  public let isSheet: Bool
  public let actions: [DialogAction]

  public init(title: String?, message: String?, isSheet: Bool, actions: [DialogAction]) {
    self.title = title
    self.message = message
    self.isSheet = isSheet
    self.actions = actions
  }
}

@MainActor
public class AsyncDialogBuilder {
  private typealias ActionContinuation = CheckedContinuation<DialogAction, Never>

  private unowned var viewController: UIViewController
  private var actionContinuation: ActionContinuation?

  private let config: AsyncDialogConfigurator

  public init(config: AsyncDialogConfigurator,
              anchor: UIViewController) {
    self.config = config
    self.viewController = anchor
  }

  deinit {
    print("Deinit \(self)")
  }

  public func invokeModal() async -> DialogAction {
    let alert = UIAlertController(title: config.title, message: config.message, preferredStyle: config.isSheet ? .actionSheet : .alert)
    config.actions.forEach { action in
      let alertAction = UIAlertAction(title: action.title,
                                      style: action.isDangerous ? .destructive : .default) { [weak self] _ in
        self?.actionContinuation?.resume(returning: action)
        self?.actionContinuation = nil
      }
      alert.addAction(alertAction)
    }
    viewController.present(alert, animated: true)
    return await withCheckedContinuation { [weak self] (continuation: ActionContinuation) in
      self?.actionContinuation = continuation
    }
  }
}
