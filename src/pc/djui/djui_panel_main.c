#include "djui.h"
#include "djui_panel.h"
#include "djui_panel_host.h"
#include "djui_panel_join.h"
#include "djui_panel_options.h"
#include "djui_panel_menu.h"
#include "djui_panel_confirm.h"
#include "src/pc/controller/controller_sdl.h"
#include "src/pc/pc_main.h"
#include "djui_panel_misc.h"
#include "pc/mods/mods.h"
#include "pc/debuglog.h"

bool gDjuiPanelMainCreated = false;

static void djui_panel_main_quit_yes(UNUSED struct DjuiBase* caller) {
    game_exit();
}

static void djui_panel_main_quit(struct DjuiBase* caller) {
    djui_panel_confirm_create(caller,
                              DLANG(MAIN, QUIT_TITLE),
                              DLANG(MAIN, QUIT_CONFIRM),
                              djui_panel_main_quit_yes);
}

void djui_panel_main_create(struct DjuiBase* caller) {
    struct DjuiThreePanel* panel = djui_panel_menu_create("\\#ff0800\\SUPER\\#1be700\\BILLY\\#00b3ff\\64\n\\#ffef00\\YAAHOUUUU");
    {
        struct DjuiBase* body = djui_three_panel_get_body(panel);
        {
            struct DjuiButton* button1 = djui_button_create(body, DLANG(MAIN, HOST), DJUI_BUTTON_STYLE_NORMAL, djui_panel_host_create);
            djui_cursor_input_controlled_center(&button1->base);

            // djui_button_create(body, DLANG(MAIN, JOIN), DJUI_BUTTON_STYLE_NORMAL, djui_panel_join_create);
            djui_button_create(body, DLANG(MAIN, OPTIONS), DJUI_BUTTON_STYLE_NORMAL, djui_panel_options_create);
            djui_button_create(body, DLANG(MAIN, QUIT), DJUI_BUTTON_STYLE_BACK, djui_panel_main_quit);
        }
        //djui_base_set_visible(&panel->base, false);
        // djui_base_set_visible(body, false);
        // djui_base_set_enabled(body, true);

        static char myVersionString[32] = "Episode 1";
        char* version = myVersionString;
        struct DjuiText* footer = djui_text_create(&panel->base, version);
        // djui_base_set_size_type(&footer->base, DJUI_SVT_RELATIVE, DJUI_SVT_ABSOLUTE);
        // djui_base_set_size(&footer->base, 1.0f, 1.0f);
        djui_base_set_size_type(&panel->base, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
        djui_base_set_size(&panel->base, 1.0f, 1.0f); // 100% width, 100% height
        djui_base_set_color(&footer->base, 50, 50, 50, 255);
        djui_text_set_alignment(footer, DJUI_HALIGN_CENTER, DJUI_VALIGN_BOTTOM);
    }
    // TODO IBRA activer tout les mods automatiquement
     for (int i = 0; i < gLocalMods.entryCount; i++) {
         struct Mod* mod = gLocalMods.entries[i];
         // mod->enabled = true;
     }

    djui_panel_add(caller, panel, NULL);
    gInteractableOverridePad = true;
    gDjuiPanelMainCreated = true;
}
