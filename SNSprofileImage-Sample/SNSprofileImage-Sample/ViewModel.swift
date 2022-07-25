//
//  ViewModel.swift
//  SNSprofileImage-Sample
//
//  Created by 木元健太郎 on 2022/07/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelInput {
   func setCrop(image: UIImage)
}

protocol ViewModelOutput {
    var successImageSet: PublishRelay<UIImage> { get }
}

protocol ViewModelType {
  var input: ViewModelInput { get }
  var output: ViewModelOutput { get }
}

final class ViewModel: ViewModelInput, ViewModelOutput, ViewModelType {
    var input: ViewModelInput { return self }
    var output: ViewModelOutput { return self }
    
    //input
    func setCrop(image: UIImage) {
        successImageSet.accept(image)
    }
    
    
    //output
    var successImageSet = PublishRelay<UIImage>()
}
