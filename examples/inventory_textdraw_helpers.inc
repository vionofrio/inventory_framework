#if defined _inventory_textdraw_helpers_included
    #endinput
#endif
#define _inventory_textdraw_helpers_included

/*
    open.mp-native PlayerTextDraw helpers.

    Coordinates and dimensions use the 640 x 480 virtual screen. Sprites and model previews
    interpret PlayerTextDrawTextSize values as width and height offsets; font 1 text boxes use
    absolute corner coordinates instead. The helpers keep these cases separate.
*/
enum e_UI_TEXT_DRAW_VALIGN
{
    UI_TEXT_DRAW_VALIGN_TOP,
    UI_TEXT_DRAW_VALIGN_MIDDLE,
    UI_TEXT_DRAW_VALIGN_BOTTOM
}

stock PlayerText:UiTextDraw_CreateText(
    playerid,
    color,
    Float:x,
    Float:y,
    const text[],
    TEXT_DRAW_FONT:font,
    Float:letterWidth,
    Float:letterHeight = 0.0,
    TEXT_DRAW_ALIGN:align = TEXT_DRAW_ALIGN_LEFT,
    e_UI_TEXT_DRAW_VALIGN:valign = UI_TEXT_DRAW_VALIGN_TOP
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || letterWidth < 0.0 || letterHeight < 0.0)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    if (letterHeight == 0.0)
    {
        letterHeight = letterWidth * 4.0;
    }

    new Float:createY;

    if (valign == UI_TEXT_DRAW_VALIGN_MIDDLE)
    {
        createY = y - (letterWidth + letterHeight) - letterHeight / 0.135 / 2.0;
    }
    else if (valign == UI_TEXT_DRAW_VALIGN_BOTTOM)
    {
        createY = y - letterHeight / 0.135;
    }
    else if (valign == UI_TEXT_DRAW_VALIGN_TOP)
    {
        createY = y - (letterWidth + letterHeight) * 2.0;
    }
    else
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    new PlayerText:textdrawId = CreatePlayerTextDraw(playerid, x, createY, text);

    if (textdrawId == PlayerText:INVALID_TEXT_DRAW)
    {
        return textdrawId;
    }

    PlayerTextDrawColour(playerid, textdrawId, color);
    PlayerTextDrawFont(playerid, textdrawId, font);
    PlayerTextDrawLetterSize(playerid, textdrawId, letterWidth, letterHeight);
    PlayerTextDrawAlignment(playerid, textdrawId, align);
    PlayerTextDrawSetOutline(playerid, textdrawId, 1);
    PlayerTextDrawSetShadow(playerid, textdrawId, 0);
    PlayerTextDrawSetProportional(playerid, textdrawId, true);

    return textdrawId;
}

stock PlayerText:UiTextDraw_CreateSprite(
    playerid,
    Float:x,
    Float:y,
    const sprite[],
    Float:width,
    Float:height,
    color = -1,
    TEXT_DRAW_ALIGN:align = TEXT_DRAW_ALIGN_LEFT,
    e_UI_TEXT_DRAW_VALIGN:valign = UI_TEXT_DRAW_VALIGN_TOP
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || width <= 0.0 || height <= 0.0)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    new
        Float:createX = x,
        Float:createY = y;

    if (align == TEXT_DRAW_ALIGN_CENTER)
    {
        createX -= width / 2.0;
    }
    else if (align == TEXT_DRAW_ALIGN_RIGHT)
    {
        createX -= width;
    }
    else if (align != TEXT_DRAW_ALIGN_LEFT)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    if (valign == UI_TEXT_DRAW_VALIGN_MIDDLE)
    {
        createY -= height / 2.0;
    }
    else if (valign == UI_TEXT_DRAW_VALIGN_BOTTOM)
    {
        createY -= height;
    }
    else if (valign != UI_TEXT_DRAW_VALIGN_TOP)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    new PlayerText:textdrawId = CreatePlayerTextDraw(playerid, createX, createY, sprite);

    if (textdrawId == PlayerText:INVALID_TEXT_DRAW)
    {
        return textdrawId;
    }

    PlayerTextDrawFont(playerid, textdrawId, TEXT_DRAW_FONT_SPRITE_DRAW);
    PlayerTextDrawColour(playerid, textdrawId, color);
    PlayerTextDrawTextSize(playerid, textdrawId, width, height);
    PlayerTextDrawSetShadow(playerid, textdrawId, 0);

    return textdrawId;
}

stock PlayerText:UiTextDraw_CreateModel(
    playerid,
    modelId,
    Float:x,
    Float:y,
    Float:width,
    Float:height,
    color = 0,
    TEXT_DRAW_ALIGN:align = TEXT_DRAW_ALIGN_LEFT,
    e_UI_TEXT_DRAW_VALIGN:valign = UI_TEXT_DRAW_VALIGN_TOP
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || width <= 0.0 || height <= 0.0)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    new
        Float:createX = x,
        Float:createY = y;

    if (align == TEXT_DRAW_ALIGN_CENTER)
    {
        createX -= width / 2.0;
    }
    else if (align == TEXT_DRAW_ALIGN_RIGHT)
    {
        createX -= width;
    }
    else if (align != TEXT_DRAW_ALIGN_LEFT)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    if (valign == UI_TEXT_DRAW_VALIGN_MIDDLE)
    {
        createY -= height / 2.0;
    }
    else if (valign == UI_TEXT_DRAW_VALIGN_BOTTOM)
    {
        createY -= height;
    }
    else if (valign != UI_TEXT_DRAW_VALIGN_TOP)
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    new PlayerText:textdrawId = CreatePlayerTextDraw(playerid, createX, createY, " ");

    if (textdrawId == PlayerText:INVALID_TEXT_DRAW)
    {
        return textdrawId;
    }

    PlayerTextDrawFont(playerid, textdrawId, TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawColour(playerid, textdrawId, -1);
    PlayerTextDrawTextSize(playerid, textdrawId, width, height);
    PlayerTextDrawUseBox(playerid, textdrawId, true);
    PlayerTextDrawBoxColour(playerid, textdrawId, 0);
    PlayerTextDrawBackgroundColour(playerid, textdrawId, color);
    PlayerTextDrawSetPreviewModel(playerid, textdrawId, modelId);

    return textdrawId;
}

stock PlayerText:UiTextDraw_CreateBox(
    playerid,
    Float:x,
    Float:y,
    Float:width,
    Float:height,
    color,
    TEXT_DRAW_ALIGN:align = TEXT_DRAW_ALIGN_LEFT,
    e_UI_TEXT_DRAW_VALIGN:valign = UI_TEXT_DRAW_VALIGN_TOP
)
{
    return UiTextDraw_CreateSprite(
        playerid,
        x,
        y,
        "LD_SPAC:white",
        width,
        height,
        color,
        align,
        valign
    );
}

stock bool:UiTextDraw_CreateButton(
    playerid,
    &PlayerText:boxId,
    &PlayerText:textId,
    const text[],
    color,
    Float:x,
    Float:y,
    Float:width,
    Float:height,
    TEXT_DRAW_FONT:font,
    fontColor = -1,
    Float:fontSize = 0.0,
    TEXT_DRAW_ALIGN:align = TEXT_DRAW_ALIGN_LEFT,
    e_UI_TEXT_DRAW_VALIGN:valign = UI_TEXT_DRAW_VALIGN_TOP
)
{
    textId = PlayerText:INVALID_TEXT_DRAW;

    if (fontSize == 0.0)
    {
        fontSize = height / 100.0;
    }

    boxId = UiTextDraw_CreateBox(
        playerid,
        x,
        y,
        width,
        height,
        color,
        align,
        valign
    );

    if (boxId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    PlayerTextDrawSetSelectable(playerid, boxId, true);

    new
        Float:textX = x,
        Float:textY = y;

    if (align == TEXT_DRAW_ALIGN_CENTER)
    {
        textX -= width / 2.0;
    }
    else if (align == TEXT_DRAW_ALIGN_RIGHT)
    {
        textX -= width;
    }
    else if (align != TEXT_DRAW_ALIGN_LEFT)
    {
        PlayerTextDrawDestroy(playerid, boxId);
        boxId = PlayerText:INVALID_TEXT_DRAW;

        return false;
    }

    if (valign == UI_TEXT_DRAW_VALIGN_MIDDLE)
    {
        textY -= height / 2.0;
    }
    else if (valign == UI_TEXT_DRAW_VALIGN_BOTTOM)
    {
        textY -= height;
    }
    else if (valign != UI_TEXT_DRAW_VALIGN_TOP)
    {
        PlayerTextDrawDestroy(playerid, boxId);
        boxId = PlayerText:INVALID_TEXT_DRAW;

        return false;
    }

    textId = UiTextDraw_CreateText(
        playerid,
        fontColor,
        textX + width / 2.0,
        textY + height / 2.0,
        text,
        font,
        fontSize,
        0.0,
        TEXT_DRAW_ALIGN_CENTER,
        UI_TEXT_DRAW_VALIGN_MIDDLE
    );

    if (textId == PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, boxId);
        boxId = PlayerText:INVALID_TEXT_DRAW;

        return false;
    }

    return true;
}
