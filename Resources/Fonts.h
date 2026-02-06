#pragma once

#include "IconsFontAwesome6.h"
#include "Fonts/nsmfont.h"
#include "Fonts/IconsFontAwesome6Brands.h"

class FontRanges : public Singleton<FontRanges> {
public:
    static constexpr ImWchar esp_ranges[] = {
        0x0020, 0x00FF, // Basic Latin + Latin Supplement
        0x0100, 0x017F, // Latin Extended-A
        0x0180, 0x024F, // Latin Extended-B
        0x1E00, 0x1EFF, // Latin Extended Additional
        0x2000, 0x206F, // General Punctuation
        0x3000, 0x30FF, // CJK Symbols and Punctuations, Hiragana, Katakana
        0x31F0, 0x31FF, // Katakana Phonetic Extensions
        0xFF00, 0xFFEF, // Half-width characters
        0xFFFD, 0xFFFD, // Invalid
        0x4e00, 0x9FAF, // CJK Ideograms
        0
    };

    static constexpr ImWchar latin_ranges[] = {
        0x0020, 0x00FF, // Basic Latin + Latin Supplement
        0x0100, 0x017F, // Latin Extended-A
        0x0180, 0x024F, // Latin Extended-B
        0x1E00, 0x1EFF, // Latin Extended Additional
        0
    };

    /* static constexpr ImWchar logo_ranges[] = {

    }; */

    static constexpr ImWchar icons_ranges[] = {
        0xf05b, 0xf05b, // ICON_FA_CROSSHAIRS
        0xf06e, 0xf06f, // ICON_FA_EYE
        0xf013, 0xf014, // ICON_FA_GEAR
        0xf007, 0xf007, // ICON_FA_USER
        0xf1ba, 0xf1ba, // ICON_FA_GUN
        0xf54c, 0xf54c, // ICON_FA_SKULL
        0xf0c0, 0xf0c0, // ICON_FA_USERS
        0xf1b9, 0xf1b9, // ICON_FA_CAR
        0xf279, 0xf279, // ICON_FA_MAP
        0xf780, 0xf780, // ICON_FA_BIOHAZARD
        0xf1b3, 0xf1b3, // ICON_FA_CUBES
        0xE000, 0xF8FF, // Private Use Area (extended range)
        0
    };

    /* static constexpr ImWchar icons_ranges_brands[] = {
        0xf392, 0xf393, // ICON_FA_DISCORD
        0xf09a, 0xf09b, // ICON_FA_FACEBOOK
        0xf1d6, 0xf1d7, // ICON_FA_QQ
        0xf167, 0xf168, // ICON_FA_YOUTUBE
        0
    }; */

    /* static constexpr ImWchar icons_ranges_esp[] = {
        0xf54c, 0xf54d, // ICON_FA_SKULL
        0xf186, 0xf187, // ICON_FA_MOON
        0xf004, 0xf005, // ICON_FA_HEART
        0
    }; */
    
    static constexpr ImWchar icons_ranges_max[] = {ICON_MIN_FA, ICON_MAX_FA, 0};
    // static constexpr ImWchar icons_ranges_brands_max[] = {ICON_MIN_FAB, ICON_MAX_16_FAB, 0};

private:
    friend class Singleton<FontRanges>;
    FontRanges() = default;
    ~FontRanges() = default;
};
