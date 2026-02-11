# J0-BlackMarket

## Installation

### 1. Add to server.cfg

```cfg
ensure J0-BlackMarket
```

Place after your framework, inventory, and target resources.

### 2. Item Setup

**qb-inventory**
- Add item to `qb-core/shared/items.lua` (or your items config)
- Copy `install/images/burner_phone.png` to `qb-inventory/html/images/`

['burner_phone'] = {
    ['name'] = 'burner_phone',
    ['label'] = 'Burner Phone',
    ['weight'] = 200,
    ['type'] = 'item',
    ['image'] = 'burner_phone.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'An untraceable phone used for black market contacts.'
},

**ox_inventory**
- Add item to `ox_inventory/data/items.lua`
- Copy `install/images/burner_phone.png` to `ox_inventory/web/images/`

['burner_phone'] = {
    label = 'Burner Phone',
    weight = 200,
    stack = false,
    close = true,
    description = 'An untraceable phone used for black market contacts.'
},

### 3. Configure

Edit `shared/config.lua` for contacts, locations, times, and dispatch.

---

Enjoy.
