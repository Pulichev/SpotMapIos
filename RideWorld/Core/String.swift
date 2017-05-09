//
//  String.swift
//  RideWorld
//
//  Created by Владислав Пуличев on 09.05.17.
//  Copyright © 2017 Владислав Пуличев. All rights reserved.
//

extension String {
   subscript (i: Int) -> Character {
      return self[index(startIndex, offsetBy: i)]
   }
   
   subscript (i: Int) -> String {
      return String(self[i] as Character)
   }
   
   subscript (r: Range<Int>) -> String {
      let start = index(startIndex, offsetBy: r.lowerBound)
      let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
      return self[Range(start ..< end)]
   }
}
