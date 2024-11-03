import SDL
import Metal
import QuartzCore

@main
struct SDLTesterApp {
    static func main() {
#if os(iOS) || os(tvOS)
        SDL_UIKitRunApp(CommandLine.argc, CommandLine.unsafeArgv, runMain)
#else
        _ = runMain(CommandLine.argc, CommandLine.unsafeArgv)
#endif
    }

    static let runMain: SDL_main_func = { _,_ in
        guard SDL_SetHint(SDL_HINT_RENDER_DRIVER, "metal") == SDL_TRUE else {
            fatalError(String(cString: SDL_GetError()))
        }


        guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
            fatalError(String(cString: SDL_GetError()))
        }
        defer {
            SDL_Quit()
        }
        var window: OpaquePointer! = nil
        var renderer: OpaquePointer! = nil

        guard SDL_CreateWindowAndRenderer(800, 600, SDL_WINDOW_METAL.rawValue, &window, &renderer) == 0 else {
            fatalError(String(cString: SDL_GetError()))
        }
        defer {
            SDL_DestroyRenderer(renderer)
            SDL_DestroyWindow(window)
        }

        guard let window, let renderer else {
            fatalError(String(cString: SDL_GetError()))
        }

        //        var info = SDL_RendererInfo()
        //        SDL_GetRendererInfo(renderer, &info)
        //        print(String(cString: info.name))


        let layer = unsafeBitCast(SDL_RenderGetMetalLayer(renderer), to: CAMetalLayer.self)

        guard let device = layer.device else {
            fatalError("no device")
        }
        guard let queue = device.makeCommandQueue() else {
            fatalError("no queue")
        }



        var event = SDL_Event()
        while (true) {
            while SDL_PollEvent(&event) != 0 {
                switch (SDL_EventType(event.type)) {
                case SDL_QUIT:
                    exit(0)
                default:
                    break
                }
            }


            autoreleasepool {
                guard let surface = layer.nextDrawable() else {
                    return
                }

                let pass = MTLRenderPassDescriptor()
                pass.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 0, blue: 1, alpha: 1)
                pass.colorAttachments[0].loadAction = .clear
                pass.colorAttachments[0].storeAction = .store
                pass.colorAttachments[0].texture = surface.texture

                let cmdBuffer = queue.makeCommandBuffer()
                let encoder = cmdBuffer?.makeRenderCommandEncoder(descriptor: pass)
                encoder?.endEncoding()
                cmdBuffer?.present(surface)
                cmdBuffer?.commit()

            }
        }
    }

}
