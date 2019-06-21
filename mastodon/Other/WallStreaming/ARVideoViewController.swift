//
//  ViewController.swift
//  WallStreaming
//
//  Created by Konrad Feiler on 15.04.18.
//  Copyright © 2018 Konrad Feiler. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARVideoViewController: UIViewController {

    var sceneView = ARSCNView()
    var videoPlayer: VideoPlayer?
    var walls = [UUID: VirtualWall]()
    var streamStarted: Bool = false
    var closeButton = MNGExpandedTouchAreaButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.frame = self.view.frame
        self.view.addSubview(self.sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = false
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        self.closeButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 15, y: 35, width: 32, height: 32)))
        self.closeButton.setImage(UIImage(named: "block")?.maskWithColor(color: UIColor.white), for: .normal)
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.closeButton.adjustsImageWhenHighlighted = false
        self.closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.closeButton.layer.cornerRadius = 16
        self.closeButton.layer.masksToBounds = true
        self.closeButton.addTarget(self, action: #selector(didTouchUpInsideCloseButton), for: .touchUpInside)
        self.view.addSubview(self.closeButton)
    }
    
    @objc func didTouchUpInsideCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            configuration.planeDetection = .vertical
        } else {
            configuration.planeDetection = .horizontal
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        videoPlayer = VideoPlayer("test")
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func startStream(in seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.videoPlayer?.play()
        }
    }

    @IBAction func restartTapped(_ sender: UIButton) {
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        resetTracking()
        streamStarted = false
    }
    
}

// MARK: - ARSCNViewDelegate

extension ARVideoViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let wall = VirtualWall(anchor: anchor)
            self.walls[anchor.identifier] = wall
            node.addChildNode(wall)
            
            if !streamStarted {
                self.sceneView.debugOptions = []
                if let videoPlayer = videoPlayer {
                    wall.setMaterial(content: videoPlayer.scene)
                }
                streamStarted = true
                startStream(in: 2)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor, let wall = self.walls[anchor.identifier] {
            wall.update(anchor: anchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            self.walls.removeValue(forKey: anchor.identifier)
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
