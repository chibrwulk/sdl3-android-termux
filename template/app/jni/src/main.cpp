#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

extern "C" int SDL_main(int argc, char *argv[]) {
    SDL_Init(SDL_INIT_VIDEO);
    SDL_Window *window = SDL_CreateWindow("SDL3 Test", 800, 600, 0);
    SDL_Renderer *renderer = SDL_CreateRenderer(window, NULL);
    
    int running = 1;
    while (running) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_EVENT_QUIT) running = 0;
            if (e.type == SDL_EVENT_KEY_DOWN && e.key.key == SDLK_ESCAPE) running = 0;
        }
        SDL_SetRenderDrawColor(renderer, 50, 100, 150, 255);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    }
    
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
