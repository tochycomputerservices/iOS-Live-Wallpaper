//
//  ImageAssetManager.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import Foundation
import MobileCoreServices
import ImageIO

// Convert the image to the right format and save it as part of live photo
class ImageAssetManager {
    
    private let imageAssetKeyIdentifier = "17"
    private let path : String

    init(path : String) { self.path = path }

    func read() -> String? {
        guard let makerNote = metadata()?.object(forKey: kCGImagePropertyMakerAppleDictionary) as! NSDictionary? else {
            return nil
        }
        return makerNote.object(forKey: imageAssetKeyIdentifier) as! String?
    }

    func write(_ dest : String, assetIdentifier : String) {
        guard let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: dest) as CFURL, kUTTypeJPEG, 1, nil)
            else { return }
        defer { CGImageDestinationFinalize(dest) }
        guard let imageSource = self.imageSource() else { return }
        guard let metadata = self.metadata()?.mutableCopy() as? NSMutableDictionary else { return }

        let makerNote = NSMutableDictionary()
        makerNote.setObject(assetIdentifier, forKey: imageAssetKeyIdentifier as NSCopying)
        metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as String as String as NSCopying)
        CGImageDestinationAddImageFromSource(dest, imageSource, 0, metadata)
    }

    private func metadata() -> NSDictionary? {
        return self.imageSource().flatMap {
            CGImageSourceCopyPropertiesAtIndex($0, 0, nil) as NSDictionary?
        }
    }

    private func imageSource() ->  CGImageSource? {
        return self.data().flatMap {
            CGImageSourceCreateWithData($0 as CFData, nil)
        }
    }

    private func data() -> Data? {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
}
