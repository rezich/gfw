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
                    if added print("Detected entity '%'.\n", name);
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

INSERTION_STRING :: #string DONE
NUM_ENTITY_TYPES :: %1;

Entity_Storage :: struct {
%3
    gens: [%1] u32;
    //types: [%1] Type : .[ %2 ];
}

Entity_Types :: enum {
    %4;
}
DONE

generate_code :: (w: Workspace) {
    items_per_bucket := 20;
    quick_sort(entity_type_names, compare_strings);
    type_names := join(..entity_type_names, ", ");
    type_names_for_enum := join(..entity_type_names, ";\n    ");
    entity_storage_string: string;
    {
        builder: String_Builder;
        defer free_buffers(*builder);

        for entity_type_names {
            print_to_builder(*builder, "    _%1: Bucket_Array(%1, %2, true);\n", it, items_per_bucket);
        }
        entity_storage_string = builder_to_string(*builder);
    }
    
    build_string := sprint(INSERTION_STRING, entity_type_names.count, type_names, entity_storage_string, type_names_for_enum);
    
    add_build_string(build_string, w);
    
    print("Adding build string:\n%\n", build_string);
}

#import "Basic";
#import "Compiler";
#import "String";
#import "Sort";
