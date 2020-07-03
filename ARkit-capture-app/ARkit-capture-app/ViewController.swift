//
//  ViewController.swift
//  testAR1
//
//  Created by Mehdi Nikkhah on 6/28/20.
//  Copyright © 2020 Choppah. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension simd_float4x4 {
    var array: [Float] {
        return [columns.0.x, columns.1.x, columns.2.x, columns.3.x,
                columns.0.y, columns.1.y, columns.2.y, columns.3.y,
                columns.0.z, columns.1.z, columns.2.z, columns.3.z,
                columns.0.w, columns.1.w, columns.2.w, columns.3.w]
    }
}

let FREQ = 1


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var recordSwitchVal: UIButton!
    
    @IBOutlet weak var buttonLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var trashButton: UIButton!
    
    var isRecording:Bool = false
    var snapshotArray:[[String:Any]] = [[String:Any]]()
    var lastTime:TimeInterval = 0
    var frameCounter:Int = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordSwitchVal.backgroundColor = .white
        recordSwitchVal.layer.cornerRadius = 4.0
        buttonLabel.backgroundColor = .white
        buttonLabel.textColor = .black
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        

        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
        
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//     
//        return node
//    }

    
    
    // Button Functionality
    
    

    
    @IBAction func recordSwitch(_ sender: UIButton) {
        sender.isSelected.toggle()
        if recordSwitchVal.isSelected{
            buttonLabel.text = "Stop Capture!"
            buttonLabel.textColor = .red
            startRecording_()
            print("Start Recording!")
        }
        else{
            buttonLabel.text = "Start Capture!"
            buttonLabel.textColor = .black
            
            stopRecording_()
            print("Stop Recording!")
        }
    }
    
    func startRecording_() {
        self.lastTime = 0;
        self.isRecording = true;
        
    }
    
    func stopRecording_() {
        self.isRecording = false;
        self.textField.text = "Saving Files!"
        DispatchQueue.global(qos: .utility).async {
            [weak self] in
            guard let self = self else {
                return
            }
            for l in self.snapshotArray {
                self.frameCounter += 1
                let image:UIImage = l["image"] as! UIImage
                let transform = l["transform"].debugDescription
                
                if let pngImg = image.pngData() {
                    let filename = self.getDocumentsDirectory().appendingPathComponent("myImg\(String(self.frameCounter)).png")
                    print(filename)
                    print("\n")
                    try? pngImg.write(to: filename)
                    
                
                    
                    let filename2 = self.getDocumentsDirectory().appendingPathComponent("transform\(String(self.frameCounter)).txt")

                    do {
                        try transform.write(to: filename2, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                    }
                    

                }
                
               
            }
            DispatchQueue.main.async {
                // update ui here
                self.textField.text = "Done"
            }
        }
        
    }

    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if self.isRecording {
            if self.lastTime == 0 || (self.lastTime + Double(1/FREQ)) < time {
                DispatchQueue.main.async { [weak self] () -> Void in
                    self!.lastTime = time;
                    

                    let image:UIImage = self!.sceneView.snapshot()
                    
                    
                    let myTransform:simd_float4x4 = (self!.sceneView.session.currentFrame?.camera.transform)!
                    
                    print(self!.sceneView.session.currentFrame?.camera.intrinsics)
                
                    let myArray:Array = myTransform.array.compactMap({$0})
                    
                    self!.snapshotArray.append([
                        "image":image,
                        "transform":myArray
                        ])
                }
            }
                    
                    
        }
    }
    
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
    @IBAction func trashFiles(_ sender: UIButton) {
        delFiles()
    }
    
    private func delFiles() {
        let fileManager = FileManager.default
        let documentPath = self.getDocumentsDirectory().path
        print("This is the document path: ", documentPath)
        
        do {
       
              let fileNames = try fileManager.contentsOfDirectory(atPath: documentPath)
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {

                    if (fileName.hasSuffix(".png")) {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                    
                    if (fileName.hasSuffix(".txt")) {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                    

                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }

        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
   
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
