Gen :: #type u64;

Handle :: struct (T: Type) {
    #assert is_subclass_of(type_info(T), "Entity");
    ptr: *T;
    gen: Gen;
    loc: Bucket_Locator;
}

Entity :: struct {
    gen: Gen = 0;
}

spawn :: (entity: $T/Entity) -> Handle(T) {
    #insert #run sprint("gen := *entity_storage.gens[Entity_Types.%];", T);
    #insert #run sprint("storage := *entity_storage._%;", T);
    locator := bucket_array_add(storage, entity);
    pointer := bucket_array_find_pointer(storage, locator);
    handle: Handle(T);
    handle.ptr = pointer;
    handle.loc = locator;
    <<gen += 1;
    pointer.gen = <<gen;
    handle.gen = pointer.gen;
    return handle;
}

despawn :: (handle: Handle($T)) {
    #insert #run sprint("storage := *entity_storage._%;", T);
    bucket_array_remove(storage, handle.loc);
}

// not sure if this is strictly necessary...?
despawn :: inline (entity: *$T/Entity) {
    despawn(make_handle(entity));
}

make_handle :: (entity: *$T/Entity) -> Handle(T) #must {
    handle: Handle(T);
    handle.ptr = entity;
    handle.gen = entity.gen;
    return handle;
}

get_from_handle :: (handle: Handle($T)) -> entity: *T = null, gone := false #must {
    if (<<handle.ptr).gen != handle.gen return gone = true;
    return handle.ptr;
}

bucket_array_find_pointer :: (using array: *Bucket_Array, locator: Bucket_Locator) -> *array.type {
    bucket := all_buckets[locator.bucket_index];
    assert(bucket.occupied[locator.slot_index] == true);
    result := *bucket.data[locator.slot_index];
    return result;
}

/*each :: inline ($T: Type) -> *Bucket_Array(T, 20 /*or GLOBAL_BUCKET_SIZE (or...) */, true) {
    // this would work, but only if every Entity's Bucket_Array had the same
    // items_per_bucket. Or, sure, we could move this to the metaprogram and
    // have it fill that out for us, or something... but, in the end, after
    // playing around with things, the way we do things now makes more sense,
    // plus ends up being more consise as well, as an added bonus.
    #insert #run sprint("return *entity_storage._%;", T);
}*/

#placeholder NUM_ENTITY_TYPES;
#placeholder entity_types;
#placeholder Entity_Storage;

entity_storage: Entity_Storage;

#import "Compiler";
