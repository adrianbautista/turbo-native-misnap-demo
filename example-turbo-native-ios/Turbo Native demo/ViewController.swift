//
//  ViewController.swift
//  Turbo Native demo
//
//  Created by Joe Masilotti on 5/25/23.
//

import UIKit

import MiSnapCore
import MiSnap
import MiSnapUX

class ViewController: UIViewController {
    private var misnapVC: MiSnapViewController?
    private var result: MiSnapResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension ViewController {
    @objc func checkFrontButtonAction() {
        let configuration = MiSnapConfiguration(for: .checkFront)
        misnapVC = MiSnapViewController(with: configuration, delegate: self)
        
        presentMiSnap(misnapVC)
    }
}

extension ViewController: MiSnapViewControllerDelegate {
    // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
    func miSnapLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle a license status here
    }
    
    func miSnapSuccess(_ result: MiSnapResult) {
        // Handle successful session results here
        self.result = result
    }
    
    func miSnapCancelled(_ result: MiSnapResult) {
        // Handle cancelled session results here
    }
    
    func miSnapException(_ exception: NSException) {
        // Handle exception that was caught by the SDK here
    }
}

extension ViewController {
    private func presentPermissionAlert(withTitle title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let openSettings = UIAlertAction(title: "Open Settings", style: .cancel) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alert.addAction(cancel)
            alert.addAction(openSettings)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentAlert(withTitle title: String?, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }

    private func presentMiSnap(_ misnap: MiSnapViewController?) {
        guard let misnap = misnap else { return }
        
        let minDiskSpace: Int = 20
        if misnap.configuration.parameters.camera.recordVideo && !MiSnapViewController.hasMinDiskSpace(minDiskSpace) {
            presentAlert(withTitle: "Not Enough Space", message: "Please, delete old/unused files to have at least \(minDiskSpace) MB of free space")
            return
        }
        
        MiSnapViewController.checkCameraPermission { granted in
            if !granted {
                var message = "Camera permission is required to capture your documents."
                if misnap.configuration.parameters.camera.recordVideo {
                    message = "Camera permission is required to capture your documents and record videos of the entire process as required by a country regulation."
                }
                
                self.presentPermissionAlert(withTitle: "Camera Permission Denied", message: message)
                return
            }
            
            if misnap.configuration.parameters.camera.recordVideo && misnap.configuration.parameters.camera.recordAudio {
                MiSnapViewController.checkMicrophonePermission { granted in
                    if !granted {
                        let message = "Microphone permission is required to record audio as required by a country regulation."
                        self.presentPermissionAlert(withTitle: "Microphone Permission Denied", message: message)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.present(misnap, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.present(misnap, animated: true)
                }
            }
        }
    }
}
