//
//  ViewController.swift
//  testproject
//
//  Created by metso on 1/23/19.
//  Copyright © 2019 metso. All rights reserved.
//

import UIKit
import Photos

enum ButtonsInfo:Int {
    case none = 0
    case one
    case two
}

class ViewController: UIViewController {

    var postImages:[ImagesInfo] = []
    var access:ServiceAccsesPhoto = ServiceAccsesPhoto.AccsesPhoto
    var infoBtn = ButtonsInfo.none

    @IBOutlet weak var colectionView: UICollectionView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var generalImage: UIImageView!
    @IBOutlet weak var addHeaderImage: UIButton!
    @IBOutlet weak var addGneralImage: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var addPostImage: UIButton!
    @IBOutlet weak var viewOfColection: UIView!
    
    @IBAction func addImage(_ sender: UIButton) {
        if sender.tag == 1 {
            infoBtn = .one
        }else {
            infoBtn = .two
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func segmen(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewOfColection.isHidden = false
        }else {
            viewOfColection.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        access.delegate = self
        configCornerRadius([generalImage,addHeaderImage,addGneralImage])
        configSegmentControl()
        colectionView.delegate = self
        colectionView.dataSource = self
        let w = colectionView.bounds.width / 3 - 5
        postImages = access.getPhotos(size: CGSize(width: w, height: w))
    }
    
    func configCornerRadius(_ view:[UIView]) {
        for v in view{
            v.layer.cornerRadius = v.bounds.width / 2
            v.layer.masksToBounds = true
        }
    }
    
    func configSegmentControl() {
        self.segmentedControl.layer.cornerRadius = 15;
        self.segmentedControl.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        self.segmentedControl.layer.borderWidth = 1
        self.segmentedControl.layer.masksToBounds = true
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .normal)
        self.segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white
            ], for: .selected)
    }
    
}

extension ViewController:UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image:UIImage? =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if infoBtn == .one {
            headerImage.image = image
        }else {
            generalImage.image = image
        }
        infoBtn = .none
        dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController:UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //colection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellimage", for: indexPath) as! CollectionViewCell
        if !postImages[indexPath.item].isLivePhoto {
            cell.videoIcon.isHidden = true
        }
        cell.img.image = postImages[indexPath.item].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width / 3 - 5
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(1)
    }
    
}
extension ViewController:ChangeMsg{
    
    func showAlert() {
        DispatchQueue.main.sync {
            let alert = UIAlertController(title: "Mo photo access ", message: "Please set access ", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func newImages(images: [ImagesInfo]) {
        print(postImages.count)
        print("delegate")
        postImages = images
        print(postImages.count)
        DispatchQueue.main.sync {
            colectionView.reloadData()
        }
    }
    
}
