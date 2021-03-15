//
//  GameViewController.swift
//  MandelbrotTutorial
//
//  Created by Silviu Pop on 5/15/15.
//  Copyright (c) 2015 WeHeartSwift. All rights reserved.
//

import UIKit
import SpriteKit



        extension SKNode {
            class func unarchiveFromFile(_ file : String) -> SKNode? {
                if let url = Bundle.main.url(forResource: file, withExtension: "sks") {
                    do {
                        var sceneData = try NSData(contentsOfFile: url.absoluteString, options: NSData.ReadingOptions.mappedIfSafe)
                        var archiver = NSKeyedUnarchiver(forReadingWith: sceneData as Data)

                        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
                        archiver.finishDecoding()
                        return scene
                    } catch {
                        return nil
                    }
                } else {
                    return nil
                }
            }
}

//Replaced with newer edition above:
//extension SKNode {
//    class func unarchiveFromFile(file : String) -> SKNode? {
//        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
//            var sceneData = NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
//
////                contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
//            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData as Data)
//
//            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
//            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
//            archiver.finishDecoding()
//            return scene
//        } else {
//            return nil
//        }
//    }
//}



class GameViewController: UIViewController, UIScrollViewDelegate {

    var node:SKSpriteNode!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .fill

            node = scene.childNode(withName: "fractal") as! SKSpriteNode

            skView.presentScene(scene)

        }
        
        updateShader(scrollView: scrollView)
        
        let imageUniform = node.shader!.uniformNamed("image")!
        
        imageUniform.textureValue = SKTexture(imageNamed: "bunny")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("GameViewController View Did Appear")
        updateShader(scrollView: scrollView)
    }
    
    func updateShader(scrollView: UIScrollView) {
        let zoomUniform = node.shader?.uniformNamed("zoom")!
        
        let offsetUniform = node.shader!.uniformNamed("offset")!
        
        var offset = scrollView.contentOffset
        
        offset.x /= scrollView.contentSize.width
        offset.y /= scrollView.contentSize.height
        
        zoomUniform?.floatValue = Float(scrollView.zoomScale)
        offsetUniform.floatVector2Value = GLKVector2Make(Float(offset.x), Float(offset.y))
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateShader(scrollView: scrollView)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateShader(scrollView: scrollView)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }

}
