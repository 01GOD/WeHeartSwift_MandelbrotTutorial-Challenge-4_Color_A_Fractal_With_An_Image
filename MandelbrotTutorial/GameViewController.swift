//
//  GameViewController.swift
//  MandelbrotTutorial
//
//  Created by Silviu Pop on 5/15/15.
//  Copyright (c) 2015 WeHeartSwift. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UIScrollViewDelegate {

    var node: SKSpriteNode?
    var skView: SKView { view as! SKView }

    private var c: GLKVector2 = GLKVector2Make(0, 0)
    private let bunnyTexture = SKTexture(imageNamed: "bunny.png")

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.maximumZoomScale = 100_000

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        pan.minimumNumberOfTouches = 2

        view.addGestureRecognizer(pan)

        setupScene()

        updateShader(scrollView: scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateShader(scrollView: scrollView)
    }

    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        var translation = sender.translation(in: view)

        translation.x /= view.frame.size.width
        translation.y /= view.frame.size.height

        c = GLKVector2Make(Float(translation.x) + c.x, Float(translation.y) + c.y)

        let cUniform = node?.shader?.uniformNamed("c")

        cUniform?.floatVector2Value = c
        sender.setTranslation(.zero, in: view)
    }

    private func setupScene() {
        let scene = SKScene(size: CGSize(width: 1024, height: 768))
        scene.shouldEnableEffects = true
        scene.scaleMode = .aspectFill

        let shader = SKShader(fileNamed: "Fractal.fsh")
        shader.addUniform(SKUniform(name: "zoom", float: Float(scrollView.zoomScale)))
        shader.addUniform(SKUniform(
            name: "offset",
            float: GLKVector2Make(
                Float(scrollView.contentOffset.x),
                Float(scrollView.contentOffset.y)
            )
        ))
        shader.addUniform(SKUniform(name: "c", float: c))
        shader.addUniform(SKUniform(name: "image", texture: bunnyTexture))

        let fractalNode = SKSpriteNode(color: .red, size: scene.size)
        fractalNode.name = "fractal"
        fractalNode.shader = shader
        fractalNode.anchorPoint = .zero

        scene.addChild(fractalNode)

        self.node = fractalNode

        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }
    
    func updateShader(scrollView: UIScrollView) {
        let zoomUniform = node?.shader?.uniformNamed("zoom")
        let offsetUniform = node?.shader?.uniformNamed("offset")
        
        var offset = scrollView.contentOffset
        
        offset.x /= scrollView.contentSize.width
        offset.y /= scrollView.contentSize.height
        
        zoomUniform?.floatValue = Float(scrollView.zoomScale)
        offsetUniform?.floatVector2Value = GLKVector2Make(Float(offset.x), Float(offset.y))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShader(scrollView: scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateShader(scrollView: scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
