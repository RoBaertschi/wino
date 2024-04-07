pub fn Vec2(comptime vec_type: type) type {
    return struct {
        x: vec_type,
        y: vec_type,
    };
}

pub const Vec2u32 = Vec2(u32);
