//
//  Storage.swift
//  lopetalk2
//
//  Created by marky RE on 5/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import Foundation
import Firebase
class StorageFirebase {

    static func uploadImage(_ image: UIImage, _ userid:String, completion: @escaping (URL?) -> Void) {
        guard let imageData = UIImagePNGRepresentation(image) else {
            print("cast png error")
            return completion(nil)
        }
        let reference = Storage.storage().reference().child("ProfilePicture/\(userid).png")
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print("upload error")
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            completion(metadata?.downloadURL())
        })
    }
}
