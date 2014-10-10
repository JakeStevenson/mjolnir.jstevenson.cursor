#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <lauxlib.h>

#define get_screen_arg(L, idx) *((NSScreen**)luaL_checkudata(L, idx, "mjolnir.screen"))

static CGDirectDisplayID toDisplayId(NSScreen* screen){
    return [[[screen deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
}

static int cursor_warpToPoint(lua_State* L){
    int x = luaL_checknumber(L, 1);
    int y = luaL_checknumber(L, 2);
    NSPoint target = CGPointMake(roundf(x), roundf(y));
    CGWarpMouseCursorPosition(target);
    return 1;
}

static int cursor_position(lua_State* L){
    NSPoint mouseLoc;
    mouseLoc = [NSEvent mouseLocation];

    lua_newtable(L);
    lua_pushnumber(L, mouseLoc.x); lua_setfield(L, -2, "x");
    lua_pushnumber(L, mouseLoc.y); lua_setfield(L, -2, "y");
    return 1;
}

static int cursor_moveToPoint(lua_State* L){
    NSScreen* screen = get_screen_arg(L, 1);
    int x = luaL_checknumber(L, 2);
    int y = luaL_checknumber(L, 3);

    CGDirectDisplayID display = toDisplayId(screen);
    CGPoint target = CGPointMake(x, y);
    CGDisplayMoveCursorToPoint(display, target);
    return 1;
}

static int cursor_screen(lua_State* L){
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    NSScreen *screen;
    while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO));

    NSScreen** screenptr = lua_newuserdata(L, sizeof(NSScreen**));
    *screenptr = screen;

    luaL_getmetatable(L, "mjolnir.screen");
    lua_setmetatable(L, -2);
    return 1;
}

static const luaL_Reg cursorlib[] = {
    {"warptopoint", cursor_warpToPoint},
    {"movetopoint", cursor_moveToPoint},
    {"position", cursor_position},
    {"screen", cursor_screen},
    {} // necessary sentinel
};


int luaopen_mjolnir_jstevenson_cursor_internal(lua_State* L) {
    luaL_newlib(L, cursorlib);
    return 1;
}
