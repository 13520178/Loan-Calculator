//
//  IAPProduct.swift
//  Future Value Calculator
//
//  Created by Phan Đăng on 7/24/20.
//  Copyright © 2020 Phan Đăng. All rights reserved.
//


import Foundation

public struct IAPProduct {
  
  public static let SwiftShopping = "PhanNhatDang.LoanCalculator.removeAds"
  
  private static let productIdentifiers: Set<ProductIdentifier> = [IAPProduct.SwiftShopping]

  public static let store = IAPHelper(productIds: IAPProduct.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
