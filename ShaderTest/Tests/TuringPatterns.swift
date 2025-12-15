//
//  TuringPatterns.swift
//  ShaderTest
//
//  Created by Porter Glines on 11/15/25.
//

import SwiftUI
import MetalKit
import MetalPerformanceShaders

struct TuringPatterns: View {
  let views: [Test] = [
    Test(view: AnyView(BasicTuringPattern()), title: "Basic"),
  ]

  @State var selectedViewIdx = 0
  var selectedViewIdxBinding: Binding<Int> {
      Binding(get: { selectedViewIdx },
              set: { val in withAnimation { selectedViewIdx = val }})
  }

  var body: some View {
      VStack {
          Picker("Pick a Shader", selection: selectedViewIdxBinding) {
              ForEach(Array(views.enumerated()), id: \.offset) { i, view in
                  Text(view.title).tag(i)
              }
          }
          .pickerStyle(.segmented)
          .padding()

          let selected = views[selectedViewIdx]
          VStack {
              Text(selected.title)
                  .font(.title)
                  .fontDesign(.serif)
              selected.view
          }
          .id(selectedViewIdx)
          .transition(BlurReplaceTransition(configuration: .downUp))
          Spacer()
      }
      .padding()
  }
}

struct BasicTuringPattern: View {
  var body: some View {
      MTKViewRepresentable()
          .frame(minHeight: 400)
          .clipShape(RoundedRectangle(cornerRadius: 20))
  }
}

struct MTKViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        context.coordinator.setup(mtkView: mtkView)
        return mtkView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeCoordinator() -> Renderer {
        Renderer()
    }
}

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var initPipelineState: MTLComputePipelineState!
    var simPipelineState: MTLComputePipelineState!
    var renderPipelineState: MTLRenderPipelineState!

    var texture0: MTLTexture!
    var texture1: MTLTexture!
    var textureIndex = 0
    
    var timeStart = Date()
    
    func setup(mtkView view: MTKView) {
        device = view.device
        commandQueue = device.makeCommandQueue()
        setupMetalPipelines()
    }
    
    func setupMetalPipelines() {
        let library = device.makeDefaultLibrary()
        let initKernelFunction = library?.makeFunction(name: "init_simulation")
        let simKernelFunction = library?.makeFunction(name: "reaction_diffusion")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_main")
        renderPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_main")
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            initPipelineState = try device.makeComputePipelineState(function: initKernelFunction!)
            simPipelineState = try device.makeComputePipelineState(function: simKernelFunction!)
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            print("Error creating compute pipeline \(error)")
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        guard size.width > 0.1 && size.height > 0.1 else { return }
        
        let simRes = 512
        let ratio = size.width / size.height
        guard ratio.isFinite && ratio > 0 else { return }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rg16Float,
            width: simRes,
            height: Int(CGFloat(simRes) / ratio),
            mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        // TODO: copy textures from previous size?
        texture0 = device.makeTexture(descriptor: textureDescriptor)
        texture1 = device.makeTexture(descriptor: textureDescriptor)
        textureIndex = 0;
        
        seedSimulation(texture: texture0)
    }
    
    func seedSimulation(texture: MTLTexture) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        encoder.setComputePipelineState(initPipelineState)
        encoder.setTexture(texture, index: 0)
        
        let w = initPipelineState.threadExecutionWidth
        let h = initPipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerGroup = MTLSizeMake(w, h, 1)
        let threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1)
        encoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        encoder.endEncoding()
        commandBuffer.commit()
    }
    
    func draw(in view: MTKView) {
        if texture0 == nil || texture1 == nil {
            mtkView(view, drawableSizeWillChange: view.drawableSize)
        }
        guard let tex0 = texture0,
              let tex1 = texture1,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        // Simulation Steps
        let subSteps = 50;
        for _ in 0..<subSteps {
            let inTex = textureIndex == 0 ? tex0 : tex1
            let outTex = textureIndex == 0 ? tex1 : tex0
            
            guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { break }
            computeEncoder.setComputePipelineState(simPipelineState)
            computeEncoder.setTexture(inTex, index: 0)
            computeEncoder.setTexture(outTex, index: 1)
            
            let w = simPipelineState.threadExecutionWidth
            let h = simPipelineState.maxTotalThreadsPerThreadgroup / w
            let threadsPerGroup = MTLSizeMake(w, h, 1)
            let threadsPerGrid = MTLSizeMake(inTex.width, inTex.height, 1)
            computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
            
            computeEncoder.endEncoding()
            textureIndex = 1 - textureIndex
        }
        
        // Display Step
        guard let drawable = view.currentDrawable,
              let renderPass = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
            commandBuffer.commit()
            return
        }
        
        let time = Float(Date().timeIntervalSince(timeStart))
        var uniforms = Uniforms(time: time)
        let finalTex = textureIndex == 0 ? tex0 : tex1
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setFragmentTexture(finalTex, index: 0)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    struct Uniforms {
        var time: Float
    }
}

#Preview {
  TuringPatterns()
}
