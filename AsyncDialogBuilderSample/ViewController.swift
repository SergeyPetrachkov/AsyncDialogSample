//
//  ViewController.swift
//  AsyncDialogBuilderSample
//
//  Created by Sergey Petrachkov on 27.12.2021.
//

import UIKit
import AsyncDialog

enum DialogToken {
  case turnBlue
  case turnGreen
}
struct CustomDialogAction: DialogAction {
  let title: String
  let isDangerous: Bool
  let action: (() -> Void)?
  let token: DialogToken
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let button = UIButton(configuration: .filled(), primaryAction: UIAction { [weak self] _ in
      guard let self = self else {
        return
      }
      Task {
        let dialog = AsyncDialogBuilder(
          config: .init(
            title: "Choose scenario",
            message: "Select any option",
            isSheet: false,
            actions: [
              CustomDialogAction(title: "Turn blue", isDangerous: true, action: nil, token: .turnBlue),
              DefaultDialogAction(title: "Print something", action: { print("Something") }),
              DefaultDialogAction.cancel()
            ]
          ),
          anchor: self
        )
        let result = await dialog.invokeModal()
        switch result {
        case let custom as CustomDialogAction:
          switch custom.token {
          case .turnBlue:
            self.view.backgroundColor = .systemBlue
          case .turnGreen:
            self.view.backgroundColor = .systemGreen
          }
        default:
          result.action?()
        }
      }
    })
    button.setTitle("Press me", for: .normal)

    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    button.widthAnchor.constraint(equalToConstant: 200).isActive = true
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
  }
}

