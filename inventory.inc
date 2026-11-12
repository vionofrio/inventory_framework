#if defined _inventory_included
    #endinput
#endif
#define _inventory_included

#include <inventory/inventory_core>
#include <inventory/inventory_property>
#include <inventory/inventory_category>
#include <inventory/inventory_definition>
#include <inventory/inventory_type>
#include <inventory/inventory_instance>
#include <inventory/inventory_handler>
#include <inventory/inventory_storage>
#include <inventory/inventory_record>
#include <inventory/inventory_overflow>
#include <inventory/inventory_container>
#include <inventory/inventory_weight>
#include <inventory/inventory_stack>
#include <inventory/inventory_attachment>
#include <inventory/inventory_operations>
#include <inventory/inventory_debug>

/*
    Inventory Framework v0.1

    Public facade.

    Modules are composed here in dependency order:

        core -> property -> category -> definition -> type -> instance -> handler      (catalog and items)
        storage -> record -> overflow -> container -> weight -> stack                  (inventory structure)
        attachment -> operations -> debug                                              (mutations and validation)

    Shared framework state and lifecycle are provided by the core module.
*/
