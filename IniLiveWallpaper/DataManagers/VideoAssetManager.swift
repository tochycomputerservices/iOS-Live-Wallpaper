//
//  VideoAssetManager.swift
//  iLiveWallpapers
//
//  Created by Apps4World on 12/4/19.
//  Copyright © 2019 Apps4World. All rights reserved.
//

import Foundation
import AVFoundation

// Convert the video to the right format and save it as part of live photo
class VideoAssetManager {
    
    private let contentIdentifier =  "com.apple.quicktime.content.identifier"
    private let stillImageTime = "com.apple.quicktime.still-image-time"
    private let quickTimeMetadata = "mdta"
    private let path : String
    private let dummyTimeRange = CMTimeRangeMake(start: CMTimeMake(value: 0, timescale: 1000), duration: CMTimeMake(value: 200, timescale: 3000))
    
    private lazy var asset : AVURLAsset = {
        let url = URL(fileURLWithPath: self.path)
        return AVURLAsset(url: url)
    }()
    
    init(path : String) { self.path = path }
    
    func readAssetIdentifier() -> String? {
        for item in metadata() {
            if item.key as? String == contentIdentifier &&
                item.keySpace!.rawValue == quickTimeMetadata {
                return item.value as? String
            }
        }
        return nil
    }
    
    func readStillImageTime() -> NSNumber? {
        if let track = track(AVMediaType.video) {
            let (reader, output) = try! self.reader(track, settings: nil)
            reader.startReading()
            
            while true {
                guard let buffer = output.copyNextSampleBuffer() else { return nil }
                if CMSampleBufferGetNumSamples(buffer) != 0 {
                    let group = AVTimedMetadataGroup(sampleBuffer: buffer)
                    for item in group?.items ?? [] {
                        if item.key as? String == stillImageTime &&
                            item.keySpace!.rawValue == quickTimeMetadata {
                            return item.numberValue
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func write(_ dest : String, assetIdentifier : String) {
        
        var audioReader : AVAssetReader? = nil
        var audioWriterInput : AVAssetWriterInput? = nil
        var audioReaderOutput : AVAssetReaderOutput? = nil
        do {
            
            guard let track = self.track(AVMediaType.video) else {
                return
            }
            let (reader, output) = try self.reader(track,
                                                   settings: [kCVPixelBufferPixelFormatTypeKey as String:
                                                    NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)])
            
            let writer = try AVAssetWriter(outputURL: URL(fileURLWithPath: dest), fileType: .mov)
            writer.metadata = [metadataFor(assetIdentifier)]
            let input = AVAssetWriterInput(mediaType: .video,
                                           outputSettings: videoSettings(track.naturalSize))
            input.expectsMediaDataInRealTime = true
            input.transform = track.preferredTransform
            writer.add(input)
            
            let url = URL(fileURLWithPath: self.path)
            let aAudioAsset : AVAsset = AVAsset(url: url)
            print("file \(url)")
            
            
            if aAudioAsset.tracks.count > 1 {
                
                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                audioWriterInput?.expectsMediaDataInRealTime = false
                if writer.canAdd(audioWriterInput!){
                    writer.add(audioWriterInput!)
                }
                print("file \(aAudioAsset.tracks(withMediaType: .audio))")
                do {
                    
                } catch {
                    fatalError("Unable to read Asset: \(error) : ")
                }
                
                do{
                    if(aAudioAsset.tracks(withMediaType: .audio).count > 1){
                        let audioTrack:AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first!
                        audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                        audioReader = try AVAssetReader(asset: aAudioAsset)
                        if (audioReader?.canAdd(audioReaderOutput!))! {
                            audioReader?.add(audioReaderOutput!)
                        } else {
                        }
                    }
                    
                }catch{
                    fatalError("Unable to read Asset: \(error) : ")
                }
                
                //let audioReader:AVAssetReader = AVAssetReader(asset: aAudioAsset, error: &error)
                
            }
            
            let adapter = metadataAdapter()
            writer.add(adapter.assetWriterInput)
            writer.startWriting()
            reader.startReading()
            writer.startSession(atSourceTime: CMTime.zero)
            
            adapter.append(AVTimedMetadataGroup(items: [metadataForStillImageTime()],
                                                timeRange: dummyTimeRange))
            
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "assetVideoWriterQueue", attributes: [])) {
                while(input.isReadyForMoreMediaData) {
                    if reader.status == .reading {
                        if let buffer = output.copyNextSampleBuffer() {
                            if !input.append(buffer) {
                                reader.cancelReading()
                            }
                        }
                    } else {
                        input.markAsFinished()
                        if reader.status == .completed && aAudioAsset.tracks.count > 1 {
                            audioReader?.startReading()
                            writer.startSession(atSourceTime: CMTime.zero)
                            let media_queue = DispatchQueue(label: "assetAudioWriterQueue", attributes: [])
                            audioWriterInput?.requestMediaDataWhenReady(on: media_queue) {
                                while (audioWriterInput?.isReadyForMoreMediaData)! {
                                    let sampleBuffer2:CMSampleBuffer? = audioReaderOutput?.copyNextSampleBuffer()
                                    if audioReader?.status == .reading && sampleBuffer2 != nil {
                                        if !(audioWriterInput?.append(sampleBuffer2!))! {
                                            audioReader?.cancelReading()
                                        }
                                    }else {
                                        audioWriterInput?.markAsFinished()
                                        writer.finishWriting() { }
                                    }
                                }
                            }
                        }
                        else {
                            writer.finishWriting() { }
                        }
                    }
                }
            }
            while writer.status == .writing {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            }
        } catch {
        }
    }
    
    private func metadata() -> [AVMetadataItem] {
        return asset.metadata(forFormat: .quickTimeMetadata)
    }
    
    private func track(_ mediaType : AVMediaType) -> AVAssetTrack? {
        return asset.tracks(withMediaType: mediaType).first
    }
    
    private func reader(_ track : AVAssetTrack, settings: [String:AnyObject]?) throws -> (AVAssetReader, AVAssetReaderOutput) {
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        let reader = try AVAssetReader(asset: asset)
        reader.add(output)
        return (reader, output)
    }
    
    private func metadataAdapter() -> AVAssetWriterInputMetadataAdaptor {
        let spec : NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
            "\(quickTimeMetadata)/\(stillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
            "com.apple.metadata.datatype.int8"            ]
        
        var desc : CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(mediaType: .metadata,
                                       outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    private func videoSettings(_ size : CGSize) -> [String:AnyObject] {
        return [
            AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
            AVVideoWidthKey: size.width as AnyObject,
            AVVideoHeightKey: size.height as AnyObject
        ]
    }
    
    private func metadataFor(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = contentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: quickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }
    
    private func metadataForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = stillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: quickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
}
