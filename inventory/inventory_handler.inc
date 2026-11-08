#if defined _inventory_handler_included
    #endinput
#endif
#define _inventory_handler_included

/*
    Inventory Framework Handler Module

    Responsibilities:
        - Lifecycle event names and context keys (public constants).
        - Per-Definition event handler registration.
        - Event dispatch for item instances and framework lifecycle events.
*/

/*
    Lifecycle event names and context keys shared by the framework and consumers.
*/
#define INVENTORY_EVENT_REMOVED ("removed")
#define INVENTORY_EVENT_SPLIT ("split")
#define INVENTORY_EVENT_MERGED ("merged")

#define INVENTORY_CONTEXT_INVENTORY_ID ("inventoryId")
#define INVENTORY_CONTEXT_SOURCE_INSTANCE_ID ("sourceInstanceId")
#define INVENTORY_CONTEXT_TRANSFERRED_AMOUNT ("transferredAmount")

/* Internal Definition record key holding the registered event handlers. */
#define ITEM_DEFINITION_DATA_HANDLERS "handlers"

/* Pawn public symbols allow 63 characters; reserve one cell for the null terminator. */
#define _INVENTORY_HANDLER_CALLBACK_NAME_SIZE (64)

stock bool:Inventory_ItemDefinition_AddHandler(
    ItemDefinition:definitionId,
    const event[],
    const functionName[]
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_ItemDefinition_IsValid(definitionId) ||
        !_Inventory_Core_IsKeyValid(event) ||
        !_Inventory_Core_IsKeyValid(functionName) ||
        strlen(functionName) >= _INVENTORY_HANDLER_CALLBACK_NAME_SIZE)
    {
        return false;
    }

    if (funcidx(functionName) == -1)
    {
        return false;
    }

    new
        Map:definitionData = _Inventory_ItemDefinition_GetData(definitionId),
        Map:handlers = INVALID_MAP,
        List<String>:eventHandlers = List<String>:0;

    if (!map_valid(definitionData))
    {
        return false;
    }

    if (map_has_str_key(definitionData, ITEM_DEFINITION_DATA_HANDLERS))
    {
        handlers = Map:map_str_get(definitionData, ITEM_DEFINITION_DATA_HANDLERS);

        if (!map_valid(handlers))
        {
            return false;
        }

        if (map_has_str_key(handlers, event))
        {
            eventHandlers = List<String>:map_str_get(handlers, event);

            if (!list_valid<String>(eventHandlers))
            {
                return false;
            }
        }
    }

    new
        String:callback = str_new(functionName);

    if (!str_valid(callback))
    {
        return false;
    }

    if (list_valid<String>(eventHandlers))
    {
        new
            callbackCount = list_size<String>(eventHandlers);

        for (new index; index < callbackCount; index++)
        {
            new
                String:registeredCallback = list_get<String>(eventHandlers, index);

            if (str_eq(callback, registeredCallback))
            {
                str_delete(callback);

                return false;
            }
        }
    }

    new
        bool:createdHandlers = false,
        bool:createdEventHandlers = false;

    if (!map_valid(handlers))
    {
        handlers = map_new();

        if (!map_valid(handlers) ||
            !map_str_add(definitionData, ITEM_DEFINITION_DATA_HANDLERS, handlers))
        {
            if (map_valid(handlers))
            {
                map_delete_deep(handlers);
            }

            str_delete(callback);

            return false;
        }

        createdHandlers = true;
    }

    if (!list_valid<String>(eventHandlers))
    {
        eventHandlers = list_new<String>();

        if (!list_valid<String>(eventHandlers))
        {
            if (createdHandlers)
            {
                map_str_remove_deep(definitionData, ITEM_DEFINITION_DATA_HANDLERS);
            }

            str_delete(callback);

            return false;
        }

        if (!map_str_add(handlers, event, List:eventHandlers))
        {
            list_delete_deep<String>(eventHandlers);

            if (createdHandlers)
            {
                map_str_remove_deep(definitionData, ITEM_DEFINITION_DATA_HANDLERS);
            }

            str_delete(callback);

            return false;
        }

        createdEventHandlers = true;
    }

    callback = str_acquire(callback);

    if (list_add<String>(eventHandlers, callback) == -1)
    {
        str_release(callback);

        if (createdEventHandlers)
        {
            map_str_remove_deep(handlers, event);
        }

        if (createdHandlers)
        {
            map_str_remove_deep(definitionData, ITEM_DEFINITION_DATA_HANDLERS);
        }

        return false;
    }

    return true;
}

stock bool:Inventory_ItemDefinition_RemoveHandler(
    ItemDefinition:definitionId,
    const event[],
    const functionName[]
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_ItemDefinition_IsValid(definitionId) ||
        !_Inventory_Core_IsKeyValid(event) ||
        !_Inventory_Core_IsKeyValid(functionName) ||
        strlen(functionName) >= _INVENTORY_HANDLER_CALLBACK_NAME_SIZE)
    {
        return false;
    }

    new
        Map:definitionData = _Inventory_ItemDefinition_GetData(definitionId);

    if (!map_valid(definitionData) || !map_has_str_key(definitionData, ITEM_DEFINITION_DATA_HANDLERS))
    {
        return false;
    }

    new
        Map:handlers = Map:map_str_get(definitionData, ITEM_DEFINITION_DATA_HANDLERS);

    if (!map_valid(handlers) || !map_has_str_key(handlers, event))
    {
        return false;
    }

    new
        List<String>:eventHandlers = List<String>:map_str_get(handlers, event);

    if (!list_valid<String>(eventHandlers))
    {
        return false;
    }

    new
        String:callback = str_new(functionName),
        callbackCount = list_size<String>(eventHandlers),
        callbackIndex = -1;

    if (!str_valid(callback))
    {
        return false;
    }

    for (new index; index < callbackCount; index++)
    {
        new
            String:registeredCallback = list_get<String>(eventHandlers, index);

        if (str_eq(callback, registeredCallback))
        {
            callbackIndex = index;
            break;
        }
    }

    str_delete(callback);

    if (callbackIndex == -1)
    {
        return false;
    }

    list_remove_deep<String>(eventHandlers, callbackIndex);

    if (list_size<String>(eventHandlers) == 0)
    {
        map_str_remove_deep(handlers, event);
    }

    if (map_size(handlers) == 0)
    {
        map_str_remove_deep(definitionData, ITEM_DEFINITION_DATA_HANDLERS);
    }

    return true;
}

stock Inventory_ItemDefinition_GetHandlerCount(
    ItemDefinition:definitionId,
    const event[]
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_ItemDefinition_IsValid(definitionId) ||
        !_Inventory_Core_IsKeyValid(event))
    {
        return 0;
    }

    new
        Map:definitionData = _Inventory_ItemDefinition_GetData(definitionId);

    if (!map_valid(definitionData) || !map_has_str_key(definitionData, ITEM_DEFINITION_DATA_HANDLERS))
    {
        return 0;
    }

    new
        Map:handlers = Map:map_str_get(definitionData, ITEM_DEFINITION_DATA_HANDLERS);

    if (!map_valid(handlers) || !map_has_str_key(handlers, event))
    {
        return 0;
    }

    new
        List<String>:eventHandlers = List<String>:map_str_get(handlers, event);

    if (!list_valid<String>(eventHandlers))
    {
        return 0;
    }

    return list_size<String>(eventHandlers);
}

stock Inventory_ItemInstance_TriggerEvent(
    ItemInstance:instanceId,
    const event[],
    Map:context
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        !_Inventory_Core_IsKeyValid(event) ||
        !map_valid(context))
    {
        return 0;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new
        ItemDefinition:definitionId = Inventory_ItemType_GetDefinition(typeId),
        Map:definitionData = _Inventory_ItemDefinition_GetData(definitionId);

    if (!map_valid(definitionData) || !map_has_str_key(definitionData, ITEM_DEFINITION_DATA_HANDLERS))
    {
        return 0;
    }

    new
        Map:handlers = Map:map_str_get(definitionData, ITEM_DEFINITION_DATA_HANDLERS);

    if (!map_valid(handlers) || !map_has_str_key(handlers, event))
    {
        return 0;
    }

    new
        List<String>:eventHandlers = List<String>:map_str_get(handlers, event);

    if (!list_valid<String>(eventHandlers))
    {
        return 0;
    }

    new
        handlerCount = list_size<String>(eventHandlers),
        List<String>:handlerSnapshot = list_new<String>();

    if (handlerCount == 0 || !list_valid<String>(handlerSnapshot))
    {
        if (list_valid<String>(handlerSnapshot))
        {
            list_delete_deep<String>(handlerSnapshot);
        }

        return 0;
    }

    /* Copy callback names so handler changes during dispatch affect later events only. */
    for (new index; index < handlerCount; index++)
    {
        new
            String:registeredCallback = list_get<String>(eventHandlers, index),
            String:callbackCopy = str_clone(registeredCallback);

        if (!str_valid(callbackCopy))
        {
            list_delete_deep<String>(handlerSnapshot);

            return 0;
        }

        callbackCopy = str_acquire(callbackCopy);

        if (list_add<String>(handlerSnapshot, callbackCopy) == -1)
        {
            str_release(callbackCopy);
            list_delete_deep<String>(handlerSnapshot);

            return 0;
        }
    }

    new
        attemptedCount = 0,
        snapshotCount = list_size<String>(handlerSnapshot);

    for (new index; index < snapshotCount; index++)
    {
        new
            String:callback = list_get<String>(handlerSnapshot, index);
        new callbackName[_INVENTORY_HANDLER_CALLBACK_NAME_SIZE];

        str_get(callback, callbackName, sizeof(callbackName));

        if (callbackName[0] == '\0')
        {
            continue;
        }

        new
            callbackResult,
            amx_err:callbackError = pawn_try_call_public(
                callbackName,
                callbackResult,
                "ii",
                _:instanceId,
                _:context
            );

        attemptedCount++;

        if (callbackError != amx_err_none)
        {
            printf(
                "[Inventory] Handler '%s' failed during event '%s' (AMX error %d).",
                callbackName,
                event,
                _:callbackError
            );
        }

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            break;
        }
    }

    list_delete_deep<String>(handlerSnapshot);

    return attemptedCount;
}

/* True when the instance's Definition has at least one handler registered for the event. */
stock bool:_Inventory_Handler_HasHandlers(
    ItemInstance:instanceId,
    const event[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    return Inventory_ItemDefinition_GetHandlerCount(Inventory_ItemType_GetDefinition(typeId), event) > 0;
}

/* Internal lifecycle event emitter. Its temporary context is valid through synchronous dispatch only. */
stock _Inventory_Handler_TriggerLifecycleEvent(
    ItemInstance:instanceId,
    const event[],
    const contextKey[],
    AnyTag:contextValue
)
{
    if (!_Inventory_Handler_HasHandlers(instanceId, event))
    {
        return 0;
    }

    new
        Map:context = map_new();

    if (!map_valid(context))
    {
        return 0;
    }

    map_str_set(context, contextKey, contextValue);

    if (!map_has_str_key(context, contextKey))
    {
        map_delete_deep(context);

        return 0;
    }

    new
        attemptedCount = Inventory_ItemInstance_TriggerEvent(instanceId, event, context);

    map_delete_deep(context);

    return attemptedCount;
}

#undef _INVENTORY_HANDLER_CALLBACK_NAME_SIZE
