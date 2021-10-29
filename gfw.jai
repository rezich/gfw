build :: () {
    w := compiler_create_workspace("Target Program");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    target_options := get_build_options(w);
    target_options.output_executable_name = "gfw";
    set_build_options(target_options, w);
    compiler_begin_intercept(w);

    add_build_file(tprint("%/main.jai", #filepath), w);

    // automatically add all entity definition source files
    entity_files := file_list("entities/");
    for entity_files add_build_string(tprint("#load \"%/%\";", #filepath, it), w);

    init(*entity_items_per_bucket);

    message_loop();

    compiler_end_intercept(w);
    set_build_options_dc(.{do_output=false});
}

#run build();

message_loop :: () {
    while true {
        message := compiler_wait_for_message();
        if !message break;
        if message.kind == {
          case .TYPECHECKED;
            typechecked := cast(*Message_Typechecked) message;
            for typechecked.structs {
                code_struct := it.expression;
                if is_subclass_of(code_struct.defined_type, "Entity") {
                    name := code_struct.defined_type.name;
                    added := array_add_if_unique(*entity_type_names, name);
                    if added {
                        print("Detected entity '%'.\n", name);
                        table_add(*entity_items_per_bucket, name, get_bucket_size(code_struct));
                    }
                }
            }
            
          case .PHASE;
            phase := cast(*Message_Phase) message;
            if phase.phase == .TYPECHECKED_ALL_WE_CAN {
                if !generated_code {
                    generate_code(message.workspace);
                    generated_code = true;
                }
            }
            
          case .COMPLETE;
            break;
        }
    }
}

generated_code := false;

entity_type_names: [..] string;
entity_items_per_bucket: Table(string, int);

INSERTION_STRING :: #string DONE
NUM_ENTITY_TYPES :: %1;

Entity_Storage :: struct {
%3
    gens: [%1] u32;
    despawning: struct {
%7    }
    //types: [%1] Type : .[ %2 ];
}

Entity_Types :: enum {
    %4;
}

reset_entity_storage :: () {
    using entity_storage;
    for 0..NUM_ENTITY_TYPES-1 gens[it] = 0;
%5}

reset_entity_storage :: (type: Entity_Types) {
    using entity_storage;
    gens[type] = 0;
    if type == {
%6    }
}

cleanup_despawning_entities :: () {
    using entity_storage;
%8}
DONE

generate_code :: (w: Workspace) {
    quick_sort(entity_type_names, compare_strings);

    type_names := join(..entity_type_names, ", ");
    type_names_for_enum := join(..entity_type_names, ";\n    ");

    entity_storage_string: string;
    entity_storage_builder: String_Builder;
    defer free_buffers(*entity_storage_builder);
    reset_entity_storage_string: string;
    reset_entity_storage_builder: String_Builder;
    defer free_buffers(*reset_entity_storage_builder);
    reset_entity_storage_individual_string: string;
    reset_entity_storage_individual_builder: String_Builder;
    defer free_buffers(*reset_entity_storage_individual_builder);
    despawning_string: string;
    despawning_builder: String_Builder;
    defer free_buffers(*despawning_builder);
    cleanup_string: string;
    cleanup_builder: String_Builder;
    defer free_buffers(*cleanup_builder);

    for it, i: entity_type_names {
        items_per_bucket, success := table_find(entity_items_per_bucket, it);
        assert(success);
        print_to_builder(*entity_storage_builder, "    _%1: Bucket_Array(%1, %2, true);\n", it, items_per_bucket);
        print_to_builder(*reset_entity_storage_builder, "    bucket_array_reset(*_%);\n", it);
        print_to_builder(*reset_entity_storage_individual_builder, "        case .%1; bucket_array_reset(*_%1);\n", it);
        print_to_builder(*despawning_builder, "        _%: [..] Bucket_Locator;\n", it);
        print_to_builder(*cleanup_builder, "    for despawning._%1 {\n        bucket_array_remove(*_%1, it);\n        //print(\"ACTUALLY despawning %1\\n\");\n    }\n    array_reset(*despawning._%1);\n", it);
    }
    
    entity_storage_string = builder_to_string(*entity_storage_builder);
    reset_entity_storage_string = builder_to_string(*reset_entity_storage_builder);
    reset_entity_storage_individual_string = builder_to_string(*reset_entity_storage_individual_builder);
    despawning_string = builder_to_string(*despawning_builder);
    cleanup_string = builder_to_string(*cleanup_builder);
    
    build_string := sprint(INSERTION_STRING, entity_type_names.count, type_names, entity_storage_string, type_names_for_enum, reset_entity_storage_string, reset_entity_storage_individual_string, despawning_string, cleanup_string);
    
    add_build_string(build_string, w);
    
    print("Adding build string:\n----\n%\n----\n", build_string);
}

get_bucket_size :: (header: *Code_Struct) -> int {
    DEFAULT_ITEMS_PER_BUCKET :: 32;
    BUCKET_SIZE_NOTE :: "bucket_size=";
    for header.notes if begins_with(it.text, BUCKET_SIZE_NOTE) {
        items_per_bucket := slice(it.text, BUCKET_SIZE_NOTE.count, 8);
        return parse_int(*items_per_bucket);
    }
    return DEFAULT_ITEMS_PER_BUCKET;
}

#import "Basic";
#import "Compiler";
#import "String";
#import "Sort";
#import "File_Utilities";
#import "Hash_Table";
