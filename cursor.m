#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <lauxlib.h>

void PostMouseEvent(CGMouseButton button, CGEventType type, const CGPoint point) 
{
	CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, point, button);
	CGEventPost(kCGHIDEventTap, theEvent);
	CFRelease(theEvent);
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

static int cursor_click(lua_State* L){
	NSPoint point = [NSEvent mouseLocation];

	CGEventRef click1_down = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft );
	CGEventRef click1_up = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseUp, point, kCGMouseButtonLeft );
	CGEventPost(kCGHIDEventTap, click1_down);
	CGEventPost(kCGHIDEventTap, click1_up);

	CFRelease(click1_up);
	CFRelease(click1_down);
	return 0;
}


static const luaL_Reg cursorlib[] = {
	{"warptopoint", cursor_warpToPoint},
	{"position", cursor_position},
	{"click", cursor_click},
	{} // necessary sentinel
};



int luaopen_mjolnir_jstevenson_cursor_internal(lua_State* L) {
	luaL_newlib(L, cursorlib);
	return 1;
}
