THREE_DIMENSIONAL :: false;

main :: () {
    init_game();

    while true {
        reset_temporary_storage();
        cleanup_despawning_entities();
        if game.should_quit break;
        maybe_present_frame();
    }

    fini_game();
}

simulate :: (dt: float) {
    // for whatever reason, our game design dictates that we need to simulate
    // Blocks before we simulate Coins...
    using entity_storage;
    for _Block simulate(it, dt);
    for _Coin simulate(it, dt);

    if input_down(.MOUSE_BUTTON_LEFT) {
        b: Block;
        b.position.x = random_get_within_range(0, xx RENDER_WIDTH);
        b.position.y = random_get_within_range(0, xx RENDER_HEIGHT);
        b.velocity.x = random_get_within_range(100, 200) * ifx random_get() % 2 == 0 then -1 else 1;
        b.velocity.y = random_get_within_range(100, 200) * ifx random_get() % 2 == 0 then -1 else 1;
        spawn(b);
    }
}

present :: (window: Window_Type) {
    Simp.update_window(window, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT);
    Simp.clear_render_target(C_BACKGROUND.x, C_BACKGROUND.y, C_BACKGROUND.z, C_BACKGROUND.w);

    // ...but we need to present Coins before we present Blocks.
    using entity_storage;
    for _Coin present(it);
    for _Block present(it);

    draw_debug_text(4, RENDER_HEIGHT - FONT_SIZE - 4, tprint("Blocks: %", _Block.count));

    draw_debug_text(4, 4, game.fps_string);
}

#load "entities/Coin.jai";
#load "entities/Block.jai";

#load "game.jai";

#import "Basic";
#import "Bucket_Array";
