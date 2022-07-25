//
//  ProfileImageViewController.swift
//  SNSprofileImage-Sample
//
//  Created by 木元健太郎 on 2022/07/25.
//

import UIKit
import RSKImageCropper
import RxSwift

final class ProfileImageViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    private let viewModel: ViewModelType = ViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 60
        inputBind()
        outputBind()
    }
    
    private func inputBind() {
        addImageButton.rx.tap.bind { [weak self] in
            let controller = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "写真を撮る", style: .default, handler: { [weak self]_ in
                self?.addCameraView()
            })
            let library = UIAlertAction(title: "ライブラリから選択", style: .default, handler: { [weak self]_ in
                self?.addImagePickerView()
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            controller.addAction(camera)
            controller.addAction(library)
            controller.addAction(cancel)
            self?.present(controller, animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func outputBind() {
        viewModel.output.successImageSet.bind { [weak self] image in
            self?.dismiss(animated: true, completion: nil)
            self?.setCrop(image: image)
        }
    }
}

//MARK: - RSKImageCropper
extension ProfileImageViewController: RSKImageCropViewControllerDelegate {
    
    private func setCrop(image: UIImage) {
        print("setCrop")
        let imageCropVC = RSKImageCropViewController(image: image, cropMode: .circle)
        imageCropVC.moveAndScaleLabel.text = "切り取り範囲を選択"
        imageCropVC.cancelButton.setTitle("キャンセル", for: .normal)
        imageCropVC.chooseButton.setTitle("完了", for: .normal)
        imageCropVC.delegate = self
        present(imageCropVC, animated: true)
    }
    
    //キャンセルを押した時の処理
     func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //完了を押した後の処理
     func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        dismiss(animated: true)
        profileImage.image = croppedImage
    }
}

//MARK: - UIImagePicker
extension ProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    // カメラの利用
    private func addCameraView() {

        // シミュレーターでカメラを使用するとアラート表示させる
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {

            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)

            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
            })

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

        } else {
            //imagePickerViewを表示する
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.delegate = self
            self.present(pickerController, animated: true, completion: nil)
        }
    }

    // ライブラリーの利用
    private func addImagePickerView() {
        //imagePickerViewを表示する
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.modalPresentationStyle = .fullScreen
        self.present(pickerController, animated: true, completion: nil)
    }

    // pickerの選択がキャンセルされた時の処理
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
    }
    // 画像が選択(撮影)された時の処理
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("The image was selected")
        print(info[UIImagePickerController.InfoKey.originalImage] as! UIImage)

        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? else {return}
        viewModel.input.setCrop(image: selectedImage)
        
    }
}
