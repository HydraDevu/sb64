#include "djui.h"
#include "djui_panel.h"
#include "djui_panel_menu.h"
#include "djui_panel_menu_options.h"
#include "djui_panel_language.h"
#include "pc/utils/misc.h"
#include "pc/configfile.h"
#include "game/hardcoded.h"
#include "djui_inputbox.h"
#include "src/pc/controller/controller_sdl.h"

#ifdef DEVELOPMENT
void djui_panel_options_debug_create(struct DjuiBase* caller) {
    struct DjuiThreePanel* panel = djui_panel_menu_create(DLANG(MISC, DEBUG_TITLE));
    struct DjuiBase* body = djui_three_panel_get_body(panel);

    {
        djui_checkbox_create(body, DLANG(MISC, FIXED_COLLISIONS), (bool*)&gLevelValues.fixCollisionBugs, NULL);
        djui_checkbox_create(body, DLANG(MISC, LUA_PROFILER), &configLuaProfiler, NULL);
        djui_checkbox_create(body, DLANG(MISC, CTX_PROFILER), &configCtxProfiler, NULL);
        djui_checkbox_create(body, DLANG(MISC, DEBUG_PRINT), &configDebugPrint, NULL);
        djui_checkbox_create(body, DLANG(MISC, DEBUG_INFO), &configDebugInfo, NULL);
        djui_checkbox_create(body, DLANG(MISC, DEBUG_ERRORS), &configDebugError, NULL);

        djui_button_create(body, DLANG(MENU, BACK), DJUI_BUTTON_STYLE_BACK, djui_panel_menu_back);
    }

    djui_panel_add(caller, panel, NULL);
}
#endif

void djui_panel_misc_create(struct DjuiBase* caller) {
    struct DjuiThreePanel* panel = djui_panel_menu_create(DLANG(MISC, MISC_TITLE));
    struct DjuiBase* body = djui_three_panel_get_body(panel);
    djui_base_set_size_type(&panel->base, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(&panel->base, 1.0f, 1.0f);
    djui_base_set_size_type(body, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(body, 1.0f, 1.0f);

    {
        djui_button_create(body, DLANG(MISC, LANGUAGE), DJUI_BUTTON_STYLE_NORMAL, djui_panel_language_create);
        struct DjuiCheckbox* checkbox1 = djui_checkbox_create(body, DLANG(MISC, PAUSE_IN_SINGLEPLAYER), &configSingleplayerPause, NULL);
        struct DjuiCheckbox* checkbox2 = djui_checkbox_create(body, DLANG(MISC, DISABLE_POPUPS), &configDisablePopups, NULL);
        struct DjuiButton* button2 = (body, DLANG(MISC, MENU_OPTIONS), DJUI_BUTTON_STYLE_NORMAL, djui_panel_main_menu_create);

        // djui_base_set_enabled(&checkbox1->base, false);
        djui_base_set_visible(&checkbox1->base, false);
        // djui_base_set_enabled(&checkbox2->base, false);
        djui_base_set_visible(&checkbox2->base, false);

#ifdef DEVELOPMENT
        djui_button_create(body, DLANG(MISC, DEBUG), DJUI_BUTTON_STYLE_NORMAL, djui_panel_options_debug_create);
#endif
        djui_button_create(body, DLANG(MENU, BACK), DJUI_BUTTON_STYLE_BACK, djui_panel_menu_back);
    }

    djui_panel_add(caller, panel, NULL);
}
