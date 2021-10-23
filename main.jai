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
    print("simulating Coin % (style: %)\n", gen, style);
}

/*present :: (using coin: *Coin) {
    print("presenting Coin %\n", gen);
}*/



Block :: struct {
    using base: Entity;
    number: int;
}

simulate :: (using block: *Block, dt: float) {
    print("simulating Block % (number: %)\n", gen, number);
}



main :: () {
    print("NUM_ENTITY_TYPES is %.\n", NUM_ENTITY_TYPES);

    print("\n");

    print("entity_storage is: %\n", entity_storage);

    some_handle: Handle(Block);
    some_other_handle: Handle(Coin);

    {
        b: Block;
        b.number = 108;
        spawn(b);
    }
    {
        c: Coin;
        c.style = .FUNKY;
        spawn(c);
    }
    {
        b: Block;
        b.number = 42;
        spawn(b);
    }
    {
        b: Block;
        b.number = 4815162342;
        spawn(b);
    }
    {
        b: Block;
        b.number = 666;
        some_handle = spawn(b);
        print("some_handle: %\n", some_handle);
    }
    {
        c: Coin;
        c.style = .FRESH;
        some_other_handle = spawn(c);
    }
    {
        b: Block;
        b.number = 777;
        spawn(b);
    }
    {
        despawn(some_handle);
    }
    //--------------------------------------------------------------------------
    {
        dt := 0.0166666;
        simulate(dt);
    }
    //--------------------------------------------------------------------------
    {
        to_despawn, gone := get_from_handle(some_other_handle);
        assert(!gone);
        if !gone {
            despawn(to_despawn);
        }
    }
    //--------------------------------------------------------------------------
    {
        dt := 0.0166666;
        simulate(dt);
    }
    //--------------------------------------------------------------------------
}

simulate :: (dt: float) {
    dt := 0.016666;
    using entity_storage;
    for _Block simulate(it, dt);
    for _Coin simulate(it, dt);
}



#load "entity.jai";

#import "Basic";
#import "Bucket_Array";
