#include <stdio.h>
#include "djui.h"
#include "djui_panel.h"
#include "djui_panel_menu.h"
#include "game/save_file.h"
#include "pc/network/network.h"
#include "pc/utils/misc.h"
#include "pc/configfile.h"
#include "pc/cheats.h"
#include "djui_inputbox.h"

static unsigned int sKnockbackIndex = 0;
struct DjuiInputbox* sPlayerAmount = NULL;

static void djui_panel_host_settings_knockback_change(UNUSED struct DjuiBase* caller) {
    switch (sKnockbackIndex) {
        case 0:  configPlayerKnockbackStrength = 10; break;
        case 1:  configPlayerKnockbackStrength = 25; break;
        default: configPlayerKnockbackStrength = 60; break;
    }
}

static bool djui_panel_host_limit_valid(void) {
    char* buffer = sPlayerAmount->buffer;
    int limit = 0;
    while (*buffer != '\0') {
        if (*buffer < '0' || *buffer > '9') { return false; }
        limit *= 10;
        limit += (*buffer - '0');
        buffer++;
    }
    return limit >= 2 && limit <= MAX_PLAYERS;
}

static void djui_panel_host_player_text_change(struct DjuiBase* caller) {
    struct DjuiInputbox* inputbox1 = (struct DjuiInputbox*)caller;
    if (djui_panel_host_limit_valid()) {
        djui_inputbox_set_text_color(inputbox1, 0, 0, 0, 255);
    } else {
        djui_inputbox_set_text_color(inputbox1, 255, 0, 0, 255);
        return;
    }
	configAmountofPlayers = atoi(sPlayerAmount->buffer);
}

void djui_panel_host_settings_create(struct DjuiBase* caller) {
    struct DjuiThreePanel* panel = djui_panel_menu_create(DLANG(HOST_SETTINGS, SETTINGS));
    djui_base_set_size_type(&panel->base, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(&panel->base, 1.0f, 1.0f);
    struct DjuiBase* body = djui_three_panel_get_body(panel);
    djui_base_set_size_type(body, DJUI_SVT_RELATIVE, DJUI_SVT_RELATIVE);
    djui_base_set_size(body, 1.0f, 1.0f);
    {
        

        struct DjuiCheckbox* checkboxintro = djui_checkbox_create(body, DLANG(HOST_SETTINGS, SKIP_INTRO_CUTSCENE), &configSkipIntro, NULL);
        struct DjuiCheckbox* checkbox1 = djui_checkbox_create(body, DLANG(HOST_SETTINGS, ENABLE_CHEATS), &configEnableCheats, NULL);
        struct DjuiCheckbox* checkbox2 = djui_checkbox_create(body, DLANG(HOST_SETTINGS, BUBBLE_ON_DEATH), &configBubbleDeath, NULL);

        djui_base_set_enabled(&checkbox1->base, false);
        djui_base_set_visible(&checkbox1->base, false);
        djui_base_set_enabled(&checkbox2->base, false);
        djui_base_set_visible(&checkbox2->base, false);

        char* iChoices[3] = { DLANG(HOST_SETTINGS, NONSOLID), DLANG(HOST_SETTINGS, SOLID), DLANG(HOST_SETTINGS, FRIENDLY_FIRE) };
        struct DjuiSelectionbox* selectionbox1 = djui_selectionbox_create(body, DLANG(HOST_SETTINGS, PLAYER_INTERACTION), iChoices, 1, &configPlayerInteraction, NULL);

        sKnockbackIndex = (configPlayerKnockbackStrength <= 20)
                        ? 0
                        : ((configPlayerKnockbackStrength <= 40) ? 1 : 2);
        char* kChoices[3] = { DLANG(HOST_SETTINGS, WEAK), DLANG(HOST_SETTINGS, NORMAL), DLANG(HOST_SETTINGS, TOO_MUCH) };
        struct DjuiSelectionbox* selectionbox2 = djui_selectionbox_create(body, DLANG(HOST_SETTINGS, KNOCKBACK_STRENGTH), kChoices, 1, &sKnockbackIndex, djui_panel_host_settings_knockback_change);

        char* lChoices[3] = { DLANG(HOST_SETTINGS, LEAVE_LEVEL), DLANG(HOST_SETTINGS, STAY_IN_LEVEL), DLANG(HOST_SETTINGS, NONSTOP) };
        struct DjuiSelectionbox* selectionbox3 = djui_selectionbox_create(body, DLANG(HOST_SETTINGS, ON_STAR_COLLECTION), lChoices, 1, &configStayInLevelAfterStar, NULL);
        djui_base_set_enabled(&selectionbox1->base, false);
        djui_base_set_visible(&selectionbox1->base, false);
        djui_base_set_enabled(&selectionbox2->base, false);
        djui_base_set_visible(&selectionbox2->base, false);
        djui_base_set_enabled(&selectionbox3->base, false);
        djui_base_set_visible(&selectionbox3->base, false);
        

        struct DjuiRect* rect1 = djui_rect_container_create(body, 32);
        {
            struct DjuiText* text1 = djui_text_create(&rect1->base, DLANG(HOST_SETTINGS, AMOUNT_OF_PLAYERS));
            djui_base_set_size_type(&text1->base, DJUI_SVT_RELATIVE, DJUI_SVT_ABSOLUTE);
            djui_base_set_color(&text1->base, 200, 200, 200, 255);
            djui_base_set_size(&text1->base, 0.585f, 64);
            djui_base_set_alignment(&text1->base, DJUI_HALIGN_LEFT, DJUI_VALIGN_TOP);

            struct DjuiInputbox* inputbox1 = djui_inputbox_create(&rect1->base, 32);
            djui_base_set_size_type(&inputbox1->base, DJUI_SVT_RELATIVE, DJUI_SVT_ABSOLUTE);
            djui_base_set_size(&inputbox1->base, 0.4f, 32);
            djui_base_set_alignment(&inputbox1->base, DJUI_HALIGN_RIGHT, DJUI_VALIGN_TOP);
            char limitString[32] = { 0 };
            snprintf(limitString, 32, "%d", configAmountofPlayers);
            djui_inputbox_set_text(inputbox1, limitString);
            djui_interactable_hook_value_change(&inputbox1->base, djui_panel_host_player_text_change);
            sPlayerAmount = inputbox1;
            
            djui_base_set_enabled(&text1->base, false);
            djui_base_set_visible(&text1->base, false);
            djui_base_set_enabled(&inputbox1->base, false);
            djui_base_set_visible(&inputbox1->base, false);
        
        }
        
        djui_button_create(body, DLANG(MENU, BACK), DJUI_BUTTON_STYLE_BACK, djui_panel_menu_back);
    }
    djui_panel_add(caller, panel, NULL);
}
