Coin :: struct {
    using base: Entity;
    my_arbitrary_member: int;
}
simulate :: (using coin: *Coin, dt: float) {
    print("simulating Coin %\n", gen);
}
present :: (using coin: *Coin) {
    print("presenting Coin %\n", gen);
}

Block :: struct {
    using base: Entity;
    number: int;
}
simulate :: (using block: *Block, dt: float) {
    print("simulating Block %\n", gen);
}

Bad :: struct {}

main :: () {
    print("NUM_ENTITY_TYPES is %.\n", NUM_ENTITY_TYPES);

    print("\n");

    print("entity_storage is: %\n", entity_storage);

    some_handle: Handle(Block);

    {
        b: Block;
        b.number = 108;
        spawn(b);
    }
    {
        b: Block;
        b.number = 42;
        spawn(b);
    }
    {
        b: Block;
        b.number = 666;
        some_handle = spawn(b);
        print("some_handle: %\n", some_handle);
    }
    {
        b: Block;
        b.number = 777;
        spawn(b);
    }
    {
        despawn(some_handle);
    }
    

    {
        dt := 0.016666;
        using entity_storage;
        for _Block simulate(it, dt);
        for _Coin simulate(it, dt);
    }
}

#load "entity.jai";

#import "Basic";
#import "Bucket_Array";
