#include "djui.h"
#include "djui_panel.h"
#include "djui_panel_menu.h"
#include "src/pc/utils/misc.h"
#include "src/pc/configfile.h"

void djui_panel_sound_create(struct DjuiBase* caller) {
    struct DjuiThreePanel* panel = djui_panel_menu_create(DLANG(SOUND, SOUND));
    struct DjuiBase* body = djui_three_panel_get_body(panel);
    djui_base_set_size_type(&panel->base, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(&panel->base, 1.0f, 1.0f);
    djui_base_set_size_type(body, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(body, 1.0f, 1.0f);
    {
        djui_slider_create(body, DLANG(SOUND, MASTER_VOLUME), &configMasterVolume, 0, 127, NULL);
        djui_slider_create(body, DLANG(SOUND, MUSIC_VOLUME), &configMusicVolume, 0, 127, NULL);
        djui_slider_create(body, DLANG(SOUND, SFX_VOLUME), &configSfxVolume, 0, 127, NULL);
        djui_slider_create(body, DLANG(SOUND, ENV_VOLUME), &configEnvVolume, 0, 127, NULL);
        djui_checkbox_create(body, DLANG(SOUND, FADEOUT), &configFadeoutDistantSounds, NULL);
        struct DjuiButton* button1 = djui_button_create(body, DLANG(MENU, BACK), DJUI_BUTTON_STYLE_BACK, djui_panel_menu_back);
        djui_cursor_input_controlled_center(&button1->base);
    }

    djui_panel_add(caller, panel, NULL);
}
