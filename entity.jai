Gen :: #type u64;

Handle :: struct (T: Type) {
    #assert is_subclass_of(type_info(T), "Entity");
    ptr: *T;
    gen: Gen;
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
    <<gen += 1;
    pointer.gen = <<gen;
    handle.gen = pointer.gen;
    return handle;
}

despawn :: (entity: *$T/Entity) {

}

despawn :: (handle: Handle($T)) {

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

/*all :: ($type: Type) -> for_expansion {
    #insert #run sprint("return *entity_storage._%.for_expansion;", type);
    //#insert #run sprint("storage := *entity_storage._%;", T);
    //return storage;
    //return null;
}*/

each :: inline ($T: Type) -> *Bucket_Array(T, 20, true) {

}

bucket_array_find_pointer :: (using array: *Bucket_Array, locator: Bucket_Locator) -> *array.type {
    bucket := all_buckets[locator.bucket_index];
    assert(bucket.occupied[locator.slot_index] == true);
    result := *bucket.data[locator.slot_index];
    return result;
}

#placeholder NUM_ENTITY_TYPES;
#placeholder entity_types;
#placeholder Entity_Storage;

entity_storage: Entity_Storage;

#import "Compiler";
