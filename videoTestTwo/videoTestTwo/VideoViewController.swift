

import UIKit
import AVKit
import Photos


class VideoViewController: UIViewController {

        //need to pass in video
        var compilation:[Any?] = []
        var clipStartTimes:[CMTime] = [CMTime.zero]
        var clipEndTimes:[NSValue] = []
        var clipEndTimesCMT:[CMTime] = [CMTime.zero]
        var  atClip = 0
        var  totalClips = 0
    
    
        var isVideoPlaying = false
        var fadeAnimation = CABasicAnimation()
        var player = AVPlayer()
         var playerLayer = AVPlayerLayer()
        var assetTrack:AVAsset?
        var playerItem:AVPlayerItem?
            
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportVideo))
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "export"), style: .plain, target: self, action: #selector(exportVideo))
            setUpClipData()
            
        }
    override func viewDidLayoutSubviews(){
        print("VideDidLayout")
        super.viewDidLayoutSubviews()
    }
        override func viewDidAppear(_ animated: Bool) {
            setUpPlayerViewController()
        }
        func setUpPlayerViewController(){
            let videoURL = Bundle.main.path(forResource: "IMG_8375", ofType: "MOV")
             playerItem = AVPlayerItem(url: URL(fileURLWithPath:videoURL!))
            assetTrack =  AVAsset(url: URL(fileURLWithPath:videoURL!))
        }

        func setUpClipData(){
            
            //Firebase populate call
            clipEndTimes = [NSValue(time:CMTimeMakeWithSeconds(4, preferredTimescale: 1)), NSValue(time: CMTimeMakeWithSeconds(10, preferredTimescale: 1)), NSValue(time: CMTimeMakeWithSeconds(22, preferredTimescale: 1)), NSValue(time: CMTimeMakeWithSeconds(60020, preferredTimescale: 1))]
            
            clipEndTimesCMT = [CMTimeMakeWithSeconds(4, preferredTimescale: 1), CMTimeMakeWithSeconds(10, preferredTimescale: 1),  CMTimeMakeWithSeconds(22, preferredTimescale: 1), CMTimeMakeWithSeconds(60020, preferredTimescale: 1)]
            
            clipStartTimes = [CMTimeMakeWithSeconds(2, preferredTimescale: 1), CMTimeMakeWithSeconds(7, preferredTimescale: 1),  CMTimeMakeWithSeconds(15, preferredTimescale: 1),  CMTimeMakeWithSeconds(60000, preferredTimescale: 1)]
   
            if clipStartTimes.count < 1{
                print("No clips")
                print("Shouldn't probably do anything else too ")
                return
            }
            totalClips = clipStartTimes.count - 1
        }
    
    func videoExported(_ session: AVAssetExportSession){
        guard session.status == AVAssetExportSession.Status.completed,
                let url = session.outputURL else{
            print("videoExported guard statement")
            return
        }
     
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
              if status == .authorized {
                  
                  PHPhotoLibrary.shared().performChanges({
                      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                      print("video done saving")
                      print(url)
                      
                  })
                    {saved, error in
                        print("Saved:")
                          print(saved)
                        print("Error: \(error?.localizedDescription)")
                          print("In saving descirpitoin")}
                                                         
                  }
            }
          } else {
              PHPhotoLibrary.shared().performChanges({
                  PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                  print("Video Authorized, and done saving")
                  print(url)
              })
                {saved, error in
                    print("Saved:")
                      print(saved)
                    print("Error: \(error?.localizedDescription)")
                      print("In saving descirpitoin")}
          }
        
    }
    
    
    //Try 4
//press the export button in the top right hand corner to start this
    //the clip start and end times are the itme it needs tostart and end
    //want to export it out 
    @objc func exportVideo() {
       //Add in track compositions
      let composition = AVMutableComposition()
   
        //player is the AVPlayer, playerItem the playerItem
        var videoTime:CMTime = CMTime.zero
      
        var firstCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        //Want to do it in a for loop eventually so that it will add in all of the time intervials in the array
               do {

                   try firstCompositionTrack!.insertTimeRange(CMTimeRange(start: CMTimeMakeWithSeconds(60, preferredTimescale: 1), duration: CMTimeMakeWithSeconds(5, preferredTimescale: 1)), of: assetTrack!.tracks[0], at: CMTime.zero)
       
               }catch{
                   print(error.localizedDescription)
                   print("error inserting time range")
                   return
               }
        
        
        var firstLayerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: firstCompositionTrack!)
        
        
        let mainInstructions = AVMutableVideoCompositionInstruction()
        mainInstructions.timeRange = CMTimeRange(start: CMTime.zero, duration : CMTimeMakeWithSeconds(60, preferredTimescale: 1))
        mainInstructions.layerInstructions = [firstLayerInstructions]
        
        let mainCompositionInst = AVMutableVideoComposition()
        mainCompositionInst.instructions = [mainInstructions]
        mainCompositionInst.frameDuration =  CMTimeMakeWithSeconds(60, preferredTimescale: 1)
        mainCompositionInst.renderSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height)
        
        var tempFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp_video_data.mov", isDirectory: false)
         tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        
        //Export Session
        let exportSession = AVAssetExportSession(asset: playerItem!.asset, presetName: AVAssetExportPreset960x540)
        print("composition information")
        print(composition)
        print(type(of: composition))
        exportSession?.determineCompatibleFileTypes(){ (fileType) in print("File types, \(fileType)")}
        exportSession?.outputURL = tempFileUrl
        exportSession?.outputFileType = AVFileType.mov
      //  exportSession?.videoComposition = AVMuta
       exportSession?.timeRange = CMTimeRange(start: CMTime.zero, duration: CMTimeMakeWithSeconds(13, preferredTimescale: 1))
        print("Going into Expprt")
        
        //Remove file URL, as needed by Swift's dumb APIs, so it has someplae to put the file
        do { // delete old video
                try FileManager.default.removeItem(at: tempFileUrl)
            } catch {
                print("Issuing removing file")
                print(error.localizedDescription)
                print(error)
            }
        
        exportSession?.exportAsynchronously {
            
           
           
                switch  exportSession?.status {
                            case .failed:
                    //https://stackoverflow.com/questions/12856488/averrorinvalidvideocomposition-11841
                                print("Failed exporter")
                                print( exportSession?.error ?? "NO ERROR")
                                print( exportSession?.error!.localizedDescription)
                            case .cancelled:
                                print("Export canceled")
                            case .completed:
                                print("Video status completed")
                                print( exportSession?.status)
                                self.videoExported( exportSession!)
                               
                            case .unknown:
                                print("Export Unknown Error")
                default: print("in break statement of exporter");
                    
                    
                    print("finished export: url of file below")
                    print(tempFileUrl)
                    print(exportSession!.error)
                    print(exportSession!.status)

            
            }
        print("out of export async")
    }
    }
    
  
}
