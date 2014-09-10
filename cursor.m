#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <lauxlib.h>

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


static const luaL_Reg cursorlib[] = {
    {"warptopoint", cursor_warpToPoint},
    {"position", cursor_position},
    {} // necessary sentinel
};


/* NOTE: The substring "mjolnir_jstevenson_foobar_internal" in the following function's name
         must match the require-path of this file, i.e. "mjolnir.jstevenson.foobar.internal". */

int luaopen_mjolnir_jstevenson_cursor_internal(lua_State* L) {
    luaL_newlib(L, cursorlib);
    return 1;
}
