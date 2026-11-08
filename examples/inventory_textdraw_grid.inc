#if defined _inventory_textdraw_grid_included
    #endinput
#endif
#define _inventory_textdraw_grid_included

/*
    Inventory TextDraw grid helpers.

    All positions and dimensions use the open.mp 640 x 480 virtual screen.
    Grid data is stored as a flat PawnPlus List<Float>, with four values per cell:
    X, Y, width, and height.
*/
enum e_UI_GRID_ALIGN
{
    UI_GRID_ALIGN_LEFT,
    UI_GRID_ALIGN_CENTER,
    UI_GRID_ALIGN_RIGHT
}

enum e_UI_GRID_VALIGN
{
    UI_GRID_VALIGN_TOP,
    UI_GRID_VALIGN_MIDDLE,
    UI_GRID_VALIGN_BOTTOM
}

enum e_UI_GRID_CELL_FIELD
{
    UI_GRID_CELL_X,
    UI_GRID_CELL_Y,
    UI_GRID_CELL_SIZE_X,
    UI_GRID_CELL_SIZE_Y
}

#define UI_GRID_CELL_FIELD_COUNT (4)

stock List<Float>:UiGrid_Create(
    Float:x,
    Float:y,
    Float:sizeX,
    Float:sizeY,
    rows,
    columns,
    Float:rowGap = 0.0,
    Float:columnGap = 0.0,
    Float:gridGap = 0.0,
    e_UI_GRID_ALIGN:align = UI_GRID_ALIGN_LEFT,
    e_UI_GRID_VALIGN:valign = UI_GRID_VALIGN_TOP
)
{
    if (rows <= 0 || columns <= 0 || sizeX <= 0.0 || sizeY <= 0.0 ||
        rowGap < 0.0 || columnGap < 0.0 || gridGap < 0.0)
    {
        return List<Float>:INVALID_LIST;
    }

    if (gridGap != 0.0)
    {
        rowGap = gridGap;
        columnGap = gridGap;
    }

    if (align == UI_GRID_ALIGN_CENTER)
    {
        x -= sizeX / 2.0;
    }
    else if (align == UI_GRID_ALIGN_RIGHT)
    {
        x -= sizeX;
    }
    else if (align != UI_GRID_ALIGN_LEFT)
    {
        return List<Float>:INVALID_LIST;
    }

    if (valign == UI_GRID_VALIGN_MIDDLE)
    {
        y -= sizeY / 2.0;
    }
    else if (valign == UI_GRID_VALIGN_BOTTOM)
    {
        y -= sizeY;
    }
    else if (valign != UI_GRID_VALIGN_TOP)
    {
        return List<Float>:INVALID_LIST;
    }

    new
        Float:cellSizeX = (sizeX - float(columns - 1) * columnGap) / float(columns),
        Float:cellSizeY = (sizeY - float(rows - 1) * rowGap) / float(rows),
        List<Float>:gridData = list_new<Float>();

    if (cellSizeX <= 0.0 || cellSizeY <= 0.0 || !list_valid<Float>(gridData))
    {
        if (list_valid<Float>(gridData))
        {
            list_delete<Float>(gridData);
        }

        return List<Float>:INVALID_LIST;
    }

    for (new cellIndex; cellIndex < rows * columns; cellIndex++)
    {
        new
            row = cellIndex / columns,
            column = cellIndex % columns;

        new
            Float:cellX = x + float(column) * (cellSizeX + columnGap),
            Float:cellY = y + float(row) * (cellSizeY + rowGap);

        if (list_add<Float>(gridData, cellX) < 0 ||
            list_add<Float>(gridData, cellY) < 0 ||
            list_add<Float>(gridData, cellSizeX) < 0 ||
            list_add<Float>(gridData, cellSizeY) < 0)
        {
            list_delete<Float>(gridData);

            return List<Float>:INVALID_LIST;
        }
    }

    return gridData;
}

stock Float:UiGrid_GetCellValue(List<Float>:gridData, cellIndex, fieldIndex)
{
    if (!list_valid<Float>(gridData) || cellIndex < 0 ||
        fieldIndex < 0 || fieldIndex >= UI_GRID_CELL_FIELD_COUNT)
    {
        return 0.0;
    }

    new valueIndex = cellIndex * UI_GRID_CELL_FIELD_COUNT + fieldIndex;

    if (valueIndex >= list_size<Float>(gridData))
    {
        return 0.0;
    }

    return list_get<Float>(gridData, valueIndex);
}

stock UiGrid_GetCellCount(List<Float>:gridData)
{
    if (!list_valid<Float>(gridData))
    {
        return 0;
    }

    return list_size<Float>(gridData) / UI_GRID_CELL_FIELD_COUNT;
}

stock Float:UiGrid_GetCellX(List<Float>:gridData, cellIndex)
{
    return UiGrid_GetCellValue(gridData, cellIndex, UI_GRID_CELL_X);
}

stock Float:UiGrid_GetCellY(List<Float>:gridData, cellIndex)
{
    return UiGrid_GetCellValue(gridData, cellIndex, UI_GRID_CELL_Y);
}

stock Float:UiGrid_GetCellSizeX(List<Float>:gridData, cellIndex)
{
    return UiGrid_GetCellValue(gridData, cellIndex, UI_GRID_CELL_SIZE_X);
}

stock Float:UiGrid_GetCellSizeY(List<Float>:gridData, cellIndex)
{
    return UiGrid_GetCellValue(gridData, cellIndex, UI_GRID_CELL_SIZE_Y);
}
