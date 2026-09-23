Config = {}

Config.ServerName = 'ORI DEGIL SERVER'

-- Starting money
Config.StartingCash = 5000
Config.StartingBank = 10000

-- Starting status
Config.StartingHunger = 100
Config.StartingThirst = 100
Config.StartingDizzy = 0

-- Taxi
Config.TaxiPayment = 2000

-- Items
Config.StartingItems = {
    sandwich = 10,
    air_ketum = 10,
    phone = 1,
    radio = 1,
    ceffox = 10,
    bandage = 10,
    powerbank = 10,
    ubat_kuat = 5,
    ubat_gegat = 5
}

Config.Items = {
    sandwich = {
        label = 'Sandwich',
        hunger = 20
    },

    air_ketum = {
        label = 'Air Ketum',
        thirst = 20
    },

    phone = {
        label = 'Phone'
    },

    radio = {
        label = 'Radio'
    },

    ceffox = {
        label = 'Ceffox'
    },

    bandage = {
        label = 'Bandage'
    },

    powerbank = {
        label = 'Powerbank',
        phoneBattery = 100
    },

    ubat_kuat = {
        label = 'Ubat Kuat',
        dizzy = -5
    },

    ubat_gegat = {
        label = 'Ubat Gegat',
        dizzy = -15,
        blurDuration = 20000
    }
}

-- Taxi locations
Config.TaxiStart = vector3(895.0, -179.0, 74.7)

Config.TaxiDestinations = {
    vector3(215.7, -810.1, 30.7),
    vector3(-1037.6, -2737.8, 20.2),
    vector3(-47.4, -1758.7, 29.4),
    vector3(1690.0, 3291.0, 41.1),
    vector3(441.0, -981.9, 30.7)
}

-- Cleaner
Config.CleanerStart = vector3(-321.5, -1545.5, 31.0)

Config.CleanerTrashPoints = {
    vector3(-318.0, -1542.0, 31.0),
    vector3(-315.0, -1547.0, 31.0),
    vector3(-311.0, -1543.0, 31.0),
    vector3(-306.0, -1548.0, 31.0)
}

Config.CleanerPayment = 500

-- Basic garage
Config.GarageLocation = vector3(215.8, -810.1, 30.7)

Config.GarageVehicles = {
    {
        label = 'Sultan',
        model = 'sultan'
    },

    {
        label = 'Blista',
        model = 'blista'
    },

    {
        label = 'Faggio',
        model = 'faggio'
    },

    {
        label = 'Sanchez',
        model = 'sanchez'
    }
}