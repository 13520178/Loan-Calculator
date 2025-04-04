//
//  GradientButton.swift
//  Loan Calculator
//
//  Created by Đăng Phan on 27/3/25.
//  Copyright © 2025 Phan Đăng. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    private let iconImageView = UIImageView()
    private let textLabel = UILabel()
    
    // MARK: - Customizable properties
    @IBInspectable var startColor: UIColor = .orange {
        didSet { updateGradient() }
    }
    
    @IBInspectable var middleColor: UIColor = .magenta {
        didSet { updateGradient() }
    }
    
    @IBInspectable var endColor: UIColor = .purple {
        didSet { updateGradient() }
    }
    
    @IBInspectable var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @IBInspectable var iconTintColor: UIColor = .yellow {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
        layoutContent()
        //self.applySoftShadow()
    }
    
    // MARK: - Setup
    private func setupButton() {
        // Gradient background
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Icon setup
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconTintColor
        addSubview(iconImageView)
        
        // Text label setup
        textLabel.textAlignment = .center
        textLabel.font = titleLabel?.font ?? UIFont.systemFont(ofSize: 17, weight: .bold)
        textLabel.textColor = .label
        addSubview(textLabel)
        
        // Hide original UIButton title
        setTitleColor(.clear, for: .normal)
    }
    
    // MARK: - Update Gradient
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, middleColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = bounds
        
        let corner: CGFloat = 8
        gradientLayer.cornerRadius = corner
        self.layer.cornerRadius = corner

        // 🧠 Cái này rất quan trọng:
        // 1. Cho shadow hiển thị
        layer.masksToBounds = false
        // 2. Nhưng vẫn bo góc gradient bên trong
        gradientLayer.masksToBounds = true
    }

    
    // MARK: - Layout content
    private func layoutContent() {
        let padding: CGFloat = 8
        let iconSize: CGFloat = bounds.height * 0.65
        
        if let title = title(for: .normal) {
            textLabel.text = title
        }
        
        let textSize = textLabel.intrinsicContentSize
        let totalWidth = iconSize + padding + textSize.width
        let startX = (bounds.width - totalWidth) / 2
        
        iconImageView.frame = CGRect(
            x: startX,
            y: (bounds.height - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
        
        textLabel.frame = CGRect(
            x: iconImageView.frame.maxX + padding,
            y: 0,
            width: textSize.width,
            height: bounds.height
        )
    }
}
