Coin :: struct {
    using base: Entity;
}

Block :: struct {
    using base: Entity;
    number: int;
}

Bad :: struct {}

main :: () {
    print("NUM_ENTITY_TYPES is %.\n", NUM_ENTITY_TYPES);

    print("\n");

    print("entity_storage is: %\n", entity_storage);

    {
        b: Block;
        b.number = 108;
        bh := spawn_with_handle(b);
        bp, gone := get_from_handle(bh);
        assert(gone == false);
        //you_cant_do_this := get_from_handle(bh);
        hnd := make_handle(bp);
    }
    {
        b: Block;
        b.number = 42;
        spawn(b);
    }
    {
        for all(Block) {
            
        }
    }
}

#load "entity.jai";

#import "Basic";
#import "Bucket_Array";
#import "Compiler"; // is_subclass_of()
#import "Hash_Table";
