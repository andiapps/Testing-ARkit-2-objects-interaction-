//
//  ViewController.swift
//  SpaceShipMuseum
//
//  Created by Brian Advent on 09.06.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //Model nodes
    var hearNode: SCNNode?
    var diamondNode: SCNNode?
    var imageNodes = [SCNNode]()
    //logic variables
    var isEngaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate & settings
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        // Set the scene to the view
        hearNode = heartScene?.rootNode
        diamondNode = diamondScene?.rootNode
        //Adding target
        diamondNode?.position = SCNVector3(0,-0.1,-0.2)
        sceneView.scene.rootNode.addChildNode(diamondNode!)
        imageNodes.append(diamondNode!)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: Bundle.main) else {
            print("No images available")
            return
        }

        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 4
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            if let shapeNode = hearNode {
                shapeNode.runAction(repeatSpin)
                node.addChildNode(shapeNode)
                imageNodes.append(node)
            }
        }
        
        return node
        
    }
    
    //renderer for game logics. For this game, calculating objects distance
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            print(distance)
            if distance < 0.10 {
                spinJump(node: imageNodes[0])
                spinJump(node: imageNodes[1])
                isEngaging = true
                print("we are close here")
            } else { isEngaging = false}
        }
    }
    
//Target object approaching effects
    func spinJump (node: SCNNode) {
        if isEngaging {return}
        let shapeNode = node.childNodes[0]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        let disappear = SCNAction.removeFromParentNode()
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(disappear)
    }
   
}
