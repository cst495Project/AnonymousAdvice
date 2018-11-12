//
//  SubjectCell.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 11/9/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class SubjectCell: UICollectionViewCell {
    private let textButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    
    fileprivate func layout(){
        addSubview(textButton)
        textButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
