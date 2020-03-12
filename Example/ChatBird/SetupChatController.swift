//
//  SetupChatController.swift
//  ChatBird
//
//  The MIT License (MIT)
//
//  Copyright (c) 2020 Velos Mobile LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import SendBirdSDK
import MobileCoreServices
import RSKImageCropper

class SetupChatController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RSKImageCropViewControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var chatNameField: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    var members: [SBDUser] = []
    var coverImageData: Data? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func imageButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            let mediaUI = UIImagePickerController()
            mediaUI.sourceType = .camera
            mediaUI.mediaTypes = [String(kUTTypeImage)]
            mediaUI.delegate = self
            self.present(mediaUI, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
            let mediaUI = UIImagePickerController()
            mediaUI.sourceType = .photoLibrary
            mediaUI.mediaTypes = [String(kUTTypeImage)]
            mediaUI.delegate = self
            self.present(mediaUI, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(photoAction)
        }
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        
        let params = SBDGroupChannelParams()
        params.coverImage = self.coverImageData
        params.add(self.members)
        params.name = chatNameField.text
        
        SBDGroupChannel.createChannel(with: params) { (channel, error) in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
            
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alertController.addAction(actionCancel)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                
                return
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        createButton.isEnabled = updatedText.count > 0
        return true
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let image = info[.originalImage] as? UIImage else { return }
            let vc = RSKImageCropViewController(image: image)
            vc.delegate = self
            vc.cropMode = .circle
            self?.present(vc, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        controller.dismiss(animated: true) { [weak self] in
            self?.imageButton.setImage(croppedImage, for: .normal)
            self?.imageButton.layer.cornerRadius = 30.0
            self?.coverImageData = croppedImage.jpegData(compressionQuality: 1.0)
        }
    }
}
