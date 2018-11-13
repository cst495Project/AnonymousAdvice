//
//  SubjectCell.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 11/9/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class SubjectCell: UICollectionViewCell {
    
    let subjectLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    fileprivate func layout(){
        addSubview(subjectLabel)
        subjectLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subjectLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        subjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subjectLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
