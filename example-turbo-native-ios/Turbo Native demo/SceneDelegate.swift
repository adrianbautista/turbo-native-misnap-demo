import Turbo
import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let navigationController = UINavigationController()
    private lazy var session: Session = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "nativeApp")
        configuration.applicationNameForUserAgent = "Turbo Native iOS"
        return Session(webViewConfiguration: configuration)

//        let session = Session(webViewConfiguration: configuration)
//        session.delegate = self
//        return session
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        visit()
    }

    private func visit() {
        let url = URL(string: "http://localhost:3000")!
        let controller = VisitableViewController(url: url)
        session.visit(controller, action: .advance)
        navigationController.pushViewController(controller, animated: true)
    }
}

extension SceneDelegate: SessionDelegate {
    func session(_ session: Turbo.Session, didProposeVisit proposal: VisitProposal) {
        let controller = VisitableViewController(url: proposal.url)
        session.visit(controller, options: proposal.options)
        navigationController.pushViewController(controller, animated: true)
    }

    func session(_ session: Turbo.Session, didFailRequestForVisitable visitable: Turbo.Visitable, error: Error) {
        // TODO: Handle errors.
    }

    func sessionWebViewProcessDidTerminate(_ session: Turbo.Session) {
        // TODO: Handle dead web view.
    }
}

extension SceneDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message got", message.body)
        
        DispatchQueue.main.async { [weak self] in
            guard let navigationController = self?.window?.rootViewController as? UINavigationController else {
                print("NavigationController not found")
                return
            }
            
            // Ensure ViewController is ready and can present other view controllers
            let viewController = ViewController()
            navigationController.pushViewController(viewController, animated: true)
            
            // Delay the MiSnap presentation slightly to ensure ViewController is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewController.checkFrontButtonAction()
            }
        }
    }
}
