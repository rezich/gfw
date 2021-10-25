WINDOW_TITLE :: "gfw sample";

WINDOW_WIDTH : s32 : 640;
WINDOW_HEIGHT : s32 : 480;

RENDER_WIDTH : u32 : 640;
RENDER_HEIGHT : u32 : 480;

DATA_DIRECTORY :: "data/fonts";

FONT_FILENAME :: "type_writer.ttf";
FONT_TTFSIZE :: 8;
FONT_SIZE :: 7;

C_BACKGROUND  : Vector4 : .{0.05,0.05,0.05,1};

TARGET_FPS :: 60;

game: struct {
    window: Window_Type;
    mode: enum {
        GAME;
        MENU;
    }
    should_quit := false;
    last_time: float64;
    elapsed_time: float64;
    fps := 0;
    fps_time := 0.0;
    fps_string : string;
    fonts: struct {
        dev: *Simp.Dynamic_Font;
    }
    player: struct {
    }
    input: Input_Container;
    input_current: [#run get_enum_count(Input_Command)] bool; // confusing name
    input_prev: Input_Container;
}

init_game :: inline () {
    x := GetSystemMetrics(SM_CXSCREEN) / 2 - WINDOW_WIDTH / 2;
    y := GetSystemMetrics(SM_CYSCREEN) / 2 - WINDOW_HEIGHT / 2;
    game.window = create_window(window_name=WINDOW_TITLE, width=WINDOW_WIDTH, height=WINDOW_HEIGHT, window_x=x, window_y=y);
    Simp.simp_init(game.window, WINDOW_WIDTH, WINDOW_HEIGHT, xx RENDER_WIDTH, xx RENDER_HEIGHT);

    set_working_directory(path_strip_filename(get_path_of_running_executable()));

    game.fonts.dev = Simp.get_font_at_size(DATA_DIRECTORY, FONT_FILENAME, FONT_TTFSIZE);
    assert(game.fonts.dev != null);

    reset_game();
}

reset_game :: () {
    using game;
    mode = .GAME;
    random_seed(xx get_time());
}

fini_game :: inline () {
}

//--------------------------------------------------------------------------------------------------

do_frame :: inline (window: Window_Type) -> did_render_frame: bool {
    handle_input_events();
    update_input_state();
    per_frame_update_mouse_position();

    return update_dt_and_fps(window);
}

maybe_present_frame :: inline () {
    did_render_frame := do_frame(game.window);
    if did_render_frame {
        Simp.swap_buffers(game.window);
        update_window_events(); // here and not above?
    }
}

update_dt_and_fps :: inline (window: Window_Type) -> bool {
    dt: float;
    now := get_time();
    if game.last_time dt = cast(float) (now - game.last_time);
    game.last_time = now;

    game.elapsed_time += dt;
    game.fps_time += dt;

    TICK_PERIOD : float64 : 1.0 / xx TARGET_FPS;
    need_to_render := false;
    while game.elapsed_time >= TICK_PERIOD {
        game.elapsed_time -= TICK_PERIOD;
        need_to_render = true;
        simulate(xx TICK_PERIOD);
    }
    if need_to_render {
        game.fps += 1;
        present(window);
    }
    if game.fps_time >= 1.0 {
        free(game.fps_string);
        game.fps_string = sprint("FPS: %", game.fps);
        game.fps_time -= 1.0;
        game.fps = 0;
    }
    return need_to_render;
}

#load "input.jai";
#load "entity.jai";
#load "util.jai";

Simp :: #import "Simp";
Texture :: Simp.Texture;

#import "Windows";
#import "Window_Creation";
#import "Basic";
#import "Math";
#import "System";
#import "Input";
#import "String"; // For path_strip_filename.
#import "Random";