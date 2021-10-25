// in need of a massive overhaul

Input_Command :: enum {
    MOVE_LEFT;
    MOVE_RIGHT;
    MOVE_UP;
    MOVE_DOWN;
}

Input_Container :: [#run get_enum_count(Input_Command)] Input_State;

Input_State :: enum {
    UP;
    PRESSED;
    DOWN;
    RELEASED;
}

handle_input_events :: inline () {
    for events_this_frame {
        if it.type == {
            case .QUIT;
                game.should_quit = true;
            case .KEYBOARD;
                key := it.key_code;
                if key == .ARROW_LEFT then game.input_current[Input_Command.MOVE_LEFT] = xx it.key_pressed;
                if key == .ARROW_RIGHT then game.input_current[Input_Command.MOVE_RIGHT] = xx it.key_pressed;
                if key == .ARROW_UP then game.input_current[Input_Command.MOVE_UP] = xx it.key_pressed;
                if key == .ARROW_DOWN then game.input_current[Input_Command.MOVE_DOWN] = xx it.key_pressed;
        }
    }
}

update_input_state :: inline () {
    for 0..#run get_enum_max(Input_Command) {
        prev := game.input_prev[it];
        if game.input_current[it] {
            if prev then game.input[it] = .DOWN;
            else game.input[it] = .PRESSED;
        }
        else {
            if prev then game.input[it] = .RELEASED;
            else game.input[it] = .UP;
        }
        game.input_current[it] = false;
    }
}

current_mouse_x, current_mouse_y: int;

per_frame_update_mouse_position :: () { 
    mouse_x, mouse_y, success := get_mouse_pointer_position(true);

    if success {
        current_mouse_x = max(mouse_x, 0);
        current_mouse_y = max(mouse_y, 0);
    }
}

input_pressed :: (key: Key_Code) -> bool {
    return cast(bool) (input_button_states[key] & Key_Current_State.START);
}

input_down :: (key: Key_Code) -> bool {
    return cast(bool) (input_button_states[key]);
}
