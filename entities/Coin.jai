Coin :: struct {
    using base: Entity;
    style: Coin_Style;
}

Coin_Style :: enum {
    WACK;
    FUNKY;
    FRESH;
    FLY;
}

simulate :: (using coin: *Coin, dt: float) {
    if despawning return;
    //print("simulating Coin#% (style: %)\n", gen, style);
}

present :: (using coin: *Coin) {
    if despawning return;
    //print("presenting Coin#%\n", gen);
}
