@_exported import cSDL

public let SDL_INIT_EVERYTHING = SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_GAMECONTROLLER | SDL_INIT_SENSOR

public struct SDLError: Swift.Error, CustomStringConvertible, CustomDebugStringConvertible {
    public let description: String
    public init() {
        description = String(cString: SDL_GetError())
    }
    public var debugDescription: String { description }
}

/// Used to indicate that you don't care what the window position is.
public let SDL_WINDOWPOS_UNDEFINED =  CInt(SDL_WINDOWPOS_UNDEFINED_MASK | (0))
/// Used to indicate that the window position should be centered.
public let SDL_WINDOWPOS_CENTERED =  CInt(SDL_WINDOWPOS_CENTERED_MASK | (0))
