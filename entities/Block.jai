Block :: struct @bucket_size=64 {
    using base: Entity;
    number: int;
}

BLOCK_SIZE :: 16;

simulate :: (using block: *Block, dt: float) {
    if despawning return;
    move_with_velocity(block, dt);
    if position.x < xx (-BLOCK_SIZE) || position.x > xx (RENDER_WIDTH + BLOCK_SIZE) || position.y < xx (-BLOCK_SIZE) || position.y > xx (RENDER_HEIGHT + BLOCK_SIZE) {
        despawn(block);
    }
}

present :: (using block: *Block) {
    if despawning return;
    Simp.set_shader_for_color();
    Simp.immediate_quad(position.x - BLOCK_SIZE/2, position.y - BLOCK_SIZE/2, position.x + BLOCK_SIZE/2, position.y + BLOCK_SIZE/2, .{1,1,1,1});
}
