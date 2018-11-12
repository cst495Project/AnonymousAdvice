//
//  LocalWorldSegmentView.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 11/8/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

// relationship, work, food, random,

import UIKit

class CustomSegmentedControlView: UIView, UIGestureRecognizerDelegate {
    
    var localSelected = true
    weak var delegate: localWorldDelegate!
    
    private let localLabel: UILabel = {
        let l = UILabel()
        l.text = "Local"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.layer.borderColor = UIColor.black.cgColor
        l.layer.borderWidth = 1
        l.layer.cornerRadius = 5
        l.clipsToBounds = true
        l.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        l.isUserInteractionEnabled = true
        return l
    }()
    
    private let worldLabel: UILabel = {
        let l = UILabel()
        l.text = "World"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.layer.borderColor = UIColor.black.cgColor
        l.layer.borderWidth = 1
        l.layer.cornerRadius = 5
        l.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        l.clipsToBounds = true
        l.isUserInteractionEnabled = true
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buttonTargets()
        layout()
    }
    
    func changeLocalLabel(to: String){
        localLabel.text = to
    }
    
    fileprivate func layout(){
        addSubview(localLabel)
        localLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        localLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        localLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        localLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(worldLabel)
        worldLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        worldLabel.leadingAnchor.constraint(equalTo: localLabel.trailingAnchor).isActive = true
        worldLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        worldLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func buttonTargets(){
        let localTap = UITapGestureRecognizer(target: self, action: #selector(localTapped))
        localTap.delegate = self
        localLabel.addGestureRecognizer(localTap)
        
        let localPress = UILongPressGestureRecognizer(target: self, action: #selector(localPressed))
        localPress.delegate = self
        localLabel.addGestureRecognizer(localPress)
        
        let worldTap = UITapGestureRecognizer(target: self, action: #selector(worldTapped))
        worldLabel.addGestureRecognizer(worldTap)
    }
    
    @objc func localTapped(_ sender: UITapGestureRecognizer){
        if !localSelected {
            localLabel.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            worldLabel.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            localSelected = true
            self.delegate.showLocal()
        }
    }
    
    @objc func localPressed(_ sender: UILongPressGestureRecognizer){
        if sender.state == .began{
            if localSelected{
                self.delegate.localPressed()
            }
        }
    }
    
    @objc func worldTapped(_ sender: UITapGestureRecognizer){
        if localSelected{
            localLabel.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            worldLabel.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            localSelected = false
            self.delegate.showWorld()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
}

protocol localWorldDelegate: class {
    func showLocal()
    func showWorld()
    func localPressed()
}
