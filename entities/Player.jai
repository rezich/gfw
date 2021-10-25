Player :: struct @bucket_size=1 {
    using base: Entity;
}

simulate :: (using player: *Player, dt: float) {
    if despawning return;
}

present :: (using player: *Player) {

}
