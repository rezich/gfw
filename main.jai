THREE_DIMENSIONAL :: false;

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
    print("simulating Coin#% (style: %)\n", gen, style);
}

present :: (using coin: *Coin) {
    print("presenting Coin#%\n", gen);
}



Block :: struct {
    using base: Entity;
    number: int;
}

simulate :: (using block: *Block, dt: float) {
    print("simulating Block#% (number: %)\n", gen, number);
}

present :: (using block: *Block) {
    print("presenting Block#%\n", gen);
}



main :: () {
    print("NUM_ENTITY_TYPES is %.\n", NUM_ENTITY_TYPES);

    print("\n");

    print("entity_storage is: %\n", entity_storage);

    some_handle: Handle(Block);
    some_other_handle: Handle(Coin);
    yet_another_handle: Handle(Block);
    final_test_handle: Handle(Block);
    // let's do the whole thing twice to prove reset_entity_storage() works
    for 0..1 {
        print("--------------------\n");
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
            b.number = 13;
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
            b.number = 77;
            yet_another_handle = spawn(b);
        }
        {
            despawn(some_handle);
        }
        {
            seven, gone := get_from_handle(yet_another_handle);
            if !gone {
                final_test_handle = get_handle(seven);
                seven.number = 7;
            }
        }
        //----------------------------------------------------------------------
        {
            print("--------------------\n");
            dt := 0.0166666;
            simulate(dt);
            present();
            print("--------------------\n");
        }
        //----------------------------------------------------------------------
        {
            to_despawn, gone := get_from_handle(some_other_handle);
            assert(!gone);
            if !gone {
                despawn(to_despawn);
            }
        }
        {
            seven, gone := get_from_handle(final_test_handle);
            if !gone {
                seven.number = 777;
            }
        }
        //----------------------------------------------------------------------
        {
            print("--------------------\n");
            dt := 0.0166666;
            simulate(dt);
            present();
            print("--------------------\n");
        }
        //----------------------------------------------------------------------
        {
            print("resetting entity_storage\n");
            reset_entity_storage();
        }
    }
}

simulate :: (dt: float) {
    // for whatever reason, our game design dictates that we need to simulate
    // Blocks before we simulate Coins...
    using entity_storage;
    for _Block simulate(it, dt);
    for _Coin simulate(it, dt);
}

present :: () {
    // ...but we need to present Coins before we present Blocks.
    using entity_storage;
    for _Coin present(it);
    for _Block present(it);
}



#load "entity.jai";

#import "Basic";
#import "Bucket_Array";
