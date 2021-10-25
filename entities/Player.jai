Player :: struct @bucket_size=1 {
    using base: Entity;
}

simulate :: (using player: *Player, dt: float) {
    if despawning return;
    if input_down(.MOUSE_BUTTON_LEFT) {
        b: Block;
        b.position.x = position.x;
        b.position.y = position.y;
        b.velocity.x = random_get_within_range(100, 200) * ifx random_get() % 2 == 0 then -1 else 1;
        b.velocity.y = random_get_within_range(100, 200) * ifx random_get() % 2 == 0 then -1 else 1;
        spawn(b);
    }
}

present :: (using player: *Player) {
    if despawning return;
    Simp.set_shader_for_color();
    Simp.immediate_quad(position.x - BLOCK_SIZE/2, position.y - BLOCK_SIZE/2, position.x + BLOCK_SIZE/2, position.y + BLOCK_SIZE/2, .{0,1,0,1});
}
