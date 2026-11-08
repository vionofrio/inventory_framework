#include <open.mp>
#include <inventory>

main()
{
    return 1;
}

public OnFilterScriptInit()
{
    new
        ItemCategory:categoryId = Inventory_ItemCategory_Define(
            "filterscript_items",
            "FilterScript Items"
        );

    printf(
        "[Inventory] FilterScript framework initialization: %s",
        categoryId != INVALID_ITEM_CATEGORY_ID ? "success" : "failed"
    );

    return categoryId != INVALID_ITEM_CATEGORY_ID;
}
