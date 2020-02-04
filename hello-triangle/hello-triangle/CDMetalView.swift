//
//  CDMetalView.swift
//  hello-triangle
//
//  Created by CrazyDecode on 2020/2/4.
//  Copyright © 2020 CrazyDecode. All rights reserved.
//

import Cocoa
import MetalKit
import simd


struct CDVertex {
    var position: vector_float4
}

class CDMetalView: MTKView {
    var vertexBuffer: MTLBuffer!
    var renderPipelineState: MTLRenderPipelineState!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        // 创建MTLDevice
        self.device = MTLCreateSystemDefaultDevice()
        // 创建顶点缓冲
        self.registerVertexBuffer()
        // 绑定shader函数
        self.registerShaders()
        
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        render()
    }
}


extension CDMetalView {
    
    /// 渲染
    func render() {
        if let renderPassDescriptor = currentRenderPassDescriptor, let drawable = currentDrawable {
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
            let commandBuffer = device!.makeCommandQueue()?.makeCommandBuffer()
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            commandEncoder?.setRenderPipelineState(renderPipelineState)
            commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            commandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
    
    // 创建顶点缓冲
    //在 Metal 中是归一化的坐标系，以屏幕中心为原点(0, 0)，且是始终不变的。
    //面对屏幕，你的右边是x正轴,上面是y正轴，屏幕指向你的为z正轴。
    //窗口范围按此单位恰好是(-1,-1)到(1,1)，即屏幕左下角坐标为（-1，-1），右上角坐标为（1,1）。
    func registerVertexBuffer() {
        let vertexArray = [
            CDVertex(position: [-1.0,  1.0, 1.0, 1.0]),
            CDVertex(position: [ 1.0,  1.0, 1.0, 1.0]),
            CDVertex(position: [ 0.0, -1.0, 1.0, 1.0]),
        ]
        vertexBuffer = device!.makeBuffer(bytes: vertexArray, length: MemoryLayout<CDVertex>.size * vertexArray.count, options: [.storageModeManaged])
    }
    
    
    /// 绑定shader函数
    func registerShaders() {
        let library = device!.makeDefaultLibrary()!
        // 绑定Shaders.metal 中shader方法
        let vertex_func = library.makeFunction(name: "CDVertexShader")
        let fragment_func = library.makeFunction(name: "CDFragmentShader")
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = fragment_func
        rpld.colorAttachments[0].pixelFormat = colorPixelFormat
        do {
            try renderPipelineState = device!.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            self.printView("\(error)")
        }
    }
}
