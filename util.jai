draw_text_outlined :: (font: *Simp.Dynamic_Font, x: s64, y: s64, text: string, color := Vector4.{1,1,1,1}, background := Vector4.{0,0,0,1}, effect_flags: Simp.Font_Effects = 0) {
    using Simp;
    draw_text(font, x-1, y,   text, background, effect_flags);
    draw_text(font, x-1, y-1, text, background, effect_flags);
    draw_text(font, x,   y-1, text, background, effect_flags);
    draw_text(font, x+1, y-1, text, background, effect_flags);
    draw_text(font, x+1, y,   text, background, effect_flags);
    draw_text(font, x+1, y+1, text, background, effect_flags);
    draw_text(font, x,   y+1, text, background, effect_flags);
    draw_text(font, x-1, y+1, text, background, effect_flags);
    draw_text(font, x, y, text, color, effect_flags);
}

draw_debug_text :: inline (x: s64, y: s64, text: string, color := Vector4.{1,1,1,1}, background := Vector4.{0,0,0,1}, effect_flags: Simp.Font_Effects = 0) {
    draw_text_outlined(game.fonts.dev, x, y, text, color, background, effect_flags);
}

get_enum_count :: ($enum_type : Type) -> s64 {
    info := type_info(enum_type);
    assert(info.type == Type_Info_Tag.ENUM);
    info_enum := cast(*Type_Info_Enum) info;
    return info_enum.values.count;
}

get_enum_max :: inline ($enum_type: Type) -> s64 {
    return get_enum_count(enum_type) - 1;
}
