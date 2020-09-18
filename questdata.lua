local _, addonTable = ...

--[[
PoliSavedVars = {}

setPoliSavedVars = function()
    PoliSavedVars.quests = C_QuestLog.GetAllCompletedQuestIDs()
end

compareQuestIDs = function()
    for k, v in pairs(addonTable.questNameToID) do
        if v ~= 57316 and v ~= 57867 then
            for i, questID in ipairs(PoliSavedVars) do
                if questID == v then
                    break
                elseif i == #PoliSavedVars then
                    print("questID not found: "..v)
                    return
                end
            end
        end
    end
    print("all questIDs found")
end


local countVerified = function(verified)
    local count = 0
    for _ in pairs(verified) do
        count = count + 1
    end
    return count
end

validateQuests = function()
    CreateFrame("GameTooltip","QuestNameScanningTooltip",nil,"GameTooltipTemplate")
    QuestNameScanningTooltip:SetOwner(UIParent,"ANCHOR_NONE")
    local verified = {}
    local count = 1
    while #PoliSavedVars.quests > 0 do
        for i=#PoliSavedVars.quests, 1, -1 do
            QuestNameScanningTooltip:ClearLines()
            QuestNameScanningTooltip:SetHyperlink("quest:"..PoliSavedVars[i])
            local tooltipQuestName = QuestNameScanningTooltipTextLeft1:GetText()
            if tooltipQuestName ~= nil then
                verified[toolTipQuestName] = PoliSavedVars.quests[i]
                table.remove(PoliSavedVars.quests)
            end
        end
    end
    PoliSavedVars.quests = verified
end]]

addonTable.innWhitelist = {

    -- Bastion
    ["Caretaker Calisaphene"] = true,
    ["Caretaker Mirene"] = true,
    ["Caretaker Theo"] = true,
    ["Inkiep"] = true,

    -- Maldraxxus
    ["Kere Kinblade"] = true,
    ["Slumbar Valorum"] = true,
    
    -- Ardenweald
    ["Flitterbit"] = true,
    ["Flwngyrr"] = true,
    ["Kewarin"] = true,
    ["Llar'reth"] = true,
    ["Nolon"] = true,
    ["Sanna"] = true,
    ["Shelynn"] = true,
    ["Taiba"] = true,
    
    -- Revendreth
    ["Absolooshun"] = true,
    ["Delia"] = true,
    ["Ima"] = true,
    ["Mims"] = true,
    ["Roller"] = true,
    ["Soultrapper Valistra"] = true,
    ["Tavian"] = true,
    ["Tremen Winefang"] = true,
    
    -- Oribos
    ["Host Ta'rela"] = true
}


addonTable.questItems = {
    [178495] = { -- Shattered Helm of Domination
        ["count"] = 0,
        ["spellID"] = 326260,
        ["cooldown"] = nil
    },
    [178140] = { -- Archonic Resonator
        ["count"] = 0,
        ["spellID"] = 325651,
        ["cooldown"] = 3
    },
    [172020] = { -- Battered Weapon
        ["count"] = 0,
        ["spellID"] = 240077,
        ["cooldown"] = 5
    },
    [178496] = { -- Baron's Warhorn
        ["count"] = 0,
        ["spellID"] = 326315,
        ["cooldown"] = 15
    },
    [178940] = { -- Vashj's Signal
        ["count"] = 0,
        ["spellID"] = 327923,
        ["cooldown"] = 30
    },
    [175409] = { -- Fractured Anima Crystal
        ["count"] = 0,
        ["spellID"] = 319892,
        ["cooldown"] = 5
    },
    [181174] = { -- Amulet of the Horsemen
        ["count"] = 0,
        ["spellID"] = 335785,
        ["cooldown"] = 20
    },
    [176445] = { -- Soulweb
        ["count"] = 0,
        ["spellID"] = 322065,
        ["cooldown"] = 4
    },
    [179921] = { -- Hydra Gutter
        ["count"] = 0,
        ["spellID"] = 329074,
        ["cooldown"] = 2
    },
    [179978] = { -- Infused Animacones
        ["count"] = 0,
        ["spellID"] = 329328,
        ["cooldown"] = 10
    },
    [174864] = { -- Droman's Hunting Horn
        ["count"] = 0,
        ["spellID"] = 316914,
        ["cooldown"] = 4
    },
    [178994] = { -- Hollowed Dredbat Fang
        ["count"] = 0,
        ["spellID"] = 318145,
        ["cooldown"] = nil
    },
    
    -- Optional
    [178791] = {
        ["count"] = 0,
        ["spellID"] = 327618,
        ["cooldown"] = 30
    },
    [177835] = {
        ["count"] = 0,
        ["spellID"] = 236946,
        ["cooldown"] = nil
    },
    [177877] = {
        ["count"] = 0,
        ["spellID"] = 324038,
        ["cooldown"] = 5
    },
    [172955] = {
        ["count"] = 0,
        ["spellID"] = 310105,
        ["cooldown"] = 6
    },
    [172950] = { -- Jar of Clay
        ["count"] = 0,
        ["spellID"] = 309343,
        ["cooldown"] = nil
    },
    [172517] = { -- Enchanted Pipes
        ["count"] = 0,
        ["spellID"] = 309678,
        ["cooldown"] = nil
    },
    [173355] = { -- Pouch of Puffpetal Powder
        ["count"] = 0,
        ["spellID"] = 311385,
        ["cooldown"] = 6
    },
    [179359] = { -- Sinstone Fragment
        ["count"] = 0,
        ["spellID"] = 328524,
        ["cooldown"] = 5
    },
     [173691] = { -- Anima Drainer
        ["count"] = 0,
        ["spellID"] = 310984,
        ["cooldown"] = nil
    },
}

addonTable.itemEquipLocToEquipSlot = {
    ["INVTYPE_AMMO"] = 0,
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = { 11, 12 },
    ["INVTYPE_TRINKET"] = { 13, 14 },
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_WEAPON"] = { 16, 17 },
    ["INVTYPE_SHIELD"] = 17,
    ["INVTYPE_2HWEAPON"] = 16,
    ["INVTYPE_WEAPONMAINHAND"] = 16,
    ["INVTYPE_WEAPONOFFHAND"] = 17,
    ["INVTYPE_HOLDABLE"] = 17, --[[
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_THROWN"] = 18,
    ["INVTYPE_RANGEDRIGHT"] = 18,
    ["INVTYPE_RELIC"] = 18,
    ["INVTYPE_TABARD"] = 19,
    ["INVTYPE_BAG"] = { 20, 21, 22, 23 }
    ["INVTYPE_QUIVER"] = { 20, 21, 22, 23 }  ]]
}

addonTable.questNameToID = {
    
    ["An Urgent Request"] = 60115,
    -- The Maw
    ["A Chilling Summons"] = 61874,
    ["Through the Shattered Sky"] = 59751,
    ["A Fractured Blade"] = 59752,
    ["Mawsworn Menace"] = 59907,
    ["Ruiner's End"] = 59753,
    ["Fear to Tread"] = 59914,
    ["On Blackened Wings"] = 59754,
    ["A Flight from Darkness"] = 59755,
    ["A Moment's Respite"] = 59756,
    ["Field Seance"] = 59757,
    ["Speaking to the Dead"] = 59758,
    ["Soul in Hand"] = 59915,
    ["The Lion's Cage"] = 59759,
    ["The Afflictor's Key"] = 59760,
    ["An Undeserved Fate"] = 59761,
    ["From the Mouths of Madness"] = 59776,
    ["By and Down the River"] = 59762,
    ["Wounds Beyond Flesh"] = 59765,
    ["A Good Axe"] = 59766,
    ["Draw Out the Darkness"] = 60644,
    ["The Path to Salvation"] = 59767,
    ["Stand as One"] = 59770,
    
    -- Oribos
    ["Stranger in an Even Stranger Land"] = 60129,
    ["No Place for the Living"] = 60148,
    ["Audience with the Arbiter"] = 60149,
    ["Tether to Home"] = 60150,
    ["A Doorway Through the Veil"] = 60151,
    ["The Eternal City"] = 60152,
    ["Understanding the Shadowlands"] = 60154,
    ["The Path to Bastion"] = 60156,
    ["Seek the Ascended"] = 59773,
    
    -- Bastion
    ["Welcome to Eternity"] = 59774,
    ["Pardon Our Dust"] = 57102,
    ["A Fate Most Noble"] = 57584,
    ["Trouble in Paradise"] = 60735,
    ["Walk the Path, Aspirant"] = 57261,
    ["A Soulbind In Need"] = 57677,
    ["The Things That Haunt Us"] = 57676,
    ["The Aspirant's Crucible"] = 57709,
    ["A Life of Service"] = 57710,
    ["A Forge Gone Cold"] = 57711,
    ["The Cycle of Anima: Etherwyrms"] = 57263,
    ["The Cycle of Anima: Flower Power"] = 57267,
    ["The Cycle of Anima: Drought Conditions"] = 57265,
    ["Light the Forge, Forgelite"] = 59920,
    ["The Work of One's Hands"] = 57713,
    ["The True Crucible Awaits"] = 57908,
    ["Assessing Your Strength"] = 57288,
    ["Assessing Your Stamina"] = 57909,
    ["Assessing Your Spirit"] = 57714,
    ["The Chamber of First Reflection"] = 57291,
    ["The First Cleansing"] = 57266,
    ["The Archon's Answer"] = 60218,
    ["All An Aspirant Can Do"] = 58174,
    ["The Temple of Purity"] = 57270,
    ["A Temple in Need"] = 57977,
    ["On the Edge of a Revelation"] = 57264,
    ["A Wayward Disciple?"] = 57716,
    ["Step Back From That Ledge, My Friend"] = 57717,
    ["A Once Sweet Sound"] = 57037,
    ["The Hand of Purification"] = 59147,
    ["Dangerous Discourse"] = 57719,
    ["The Enemy You Know"] = 57446,
    ["The Hand of Doubt"] = 57269,
    ["Purity's Prerogative"] = 57447,
    ["Chasing a Memory"] = 58976,
    ["Directions Not Included"] = 58771,
    ["The Prime's Directive"] = 58799,
    ["The Mnemonic Locus"] = 58800,
    ["What's In a Memory?"] = 58977,
    ["Lysonia's Truth"] = 58978,
    ["I MADE You!"] = 58979,
    ["Mnemis, At Your Service"] = 58980,
    ["The Vault of the Archon"] = 58843,
    ["A Paragon's Reflection"] = 60180,
    ["Leave it to Mnemis"] = 60013,
    ["Go in Service"] = 59196,
    ["Your Personal Assistant"] = 59426,
    ["Steward at Work"] = 59197,
    ["On Swift Wings"] = 59198,
    ["Kyrestia, the Firstborne"] = 59199,
    ["The Wards of Bastion"] = 59200,
    ["Imminent Danger"] = 60005,
    ["Now or Never"] = 60006,
    ["Rip and Tear"] = 60008,
    ["Stay Scrappy"] = 60007,
    ["Fight Another Day"] = 60009,
    ["Clear as Crystal"] = 60053,
    ["Double Tap"] = 60052,
    ["The Final Countdown"] = 60054,
    ["A Time for Courage"] = 60055,
    ["Follow the Path"] = 60056,
    
    -- Oribos
    ["The Arbiter's Will"] = 61096,
    ["A Land of Strife"] = 61107,
    ["If You Want Peace..."] = 57386,
    
    -- Maldraxxus
    ["To Die By the Sword"] = 57390,
    ["An Opportunistic Strike"] = 60020,
    ["Champion the Cause"] = 60021,
    ["Land of Opportunity"] = 57425,
    ["Arms for the Poor"] = 57511,
    ["Memory of Honor"] = 60179,
    ["Walk Among Death"] = 57512,
    ["Trench Warfare"] = 60181,
    ["The House of the Chosen"] = 57515,
    ["The First Act of War"] = 57514,
    ["The Hills Have Eyes"] = 58351,
    ["Maintaining Order"] = 58617,
    ["Never Enough"] = 60451,
    ["Through the Fire and Flames"] = 57516,
    ["Forging a Champion"] = 58616,
    ["Ossein Enchantment"] = 58618,
    ["Thick Skin"] = 58726,
    ["The Blade of the Primus"] = 60428,
    ["The Path to Glory"] = 60453,
    ["Meet the Margrave"] = 60461,
    ["The Seat of the Primus"] = 60886,
    ["A Common Peril"] = 58751,
    ["The House of Plagues"] = 59130,
    ["Baron of the Chosen"] = 57912,
    ["Lead By Example"] = 57976,
    ["First Time? You Have to Fight!"] = 60557,
    ["Take the High Ground"] = 58268,
    ["Offensive Behavior"] = 57979,
    ["Army of One"] = 59616,
    ["Archon Save Us"] = 57983,
    ["The Ones in Charge"] = 57984,
    ["A Burden Worth Bearing"] = 57986,
    ["A Deadly Distraction"] = 57987,
    ["Give Them a Hand"] = 57985,
    ["Breaking Down Barriers"] = 57982,
    ["Two of Them, Two of Us"] = 57993,
    ["In The Flesh"] = 57994,
    ["Front and Center"] = 60733,
    ["Bug Bites"] = 58011,
    ["Spores Galore"] = 58016,
    ["Slime, Anyone?"] = 58027,
    ["Hazardous Waste Collection"] = 58036,
    ["Plague is Thicker Than Water"] = 58045,
    ["Applied Science"] = 58031,
    ["By Any Other Name"] = 59223,
    ["Fit For a Margrave"] = 60831,
    ["Fathomless Power"] = 59231,
    ["Glorious Pursuits"] = 58821,
    ["Prey Upon Them"] = 59171,
    ["War is Deception"] = 59172,
    ["Entangling Web"] = 59185,
    ["Tainted Cores"] = 59210,
    ["Vaunted Vengeance"] = 59188,
    ["Seek Your Mark"] = 59190,
    ["Straight to the Heart"] = 59025,
    ["Her Rightful Place"] = 59009,
    ["Among the Chosen"] = 59202,
    ["The Maw"] = 59874,
    
    -- Oribos
    ["Seeking the Baron"] = 59897,
    
    -- The Maw
    ["The Hunt for the Baron"] = 60972,
    ["A Cooling Trail"] = 59960,
    ["The Brand Holds the Key"] = 59959,
    ["Hope Never Dies"] = 59962,
    ["Delving Deeper"] = 59966,
    ["A Bond Beyond Death"] = 59973,
    ["Wake of Ashes"] = 61190,
    ["Maw Walker"] = 62654,
    
    -- Oribos
    ["A Soul Saved"] = 59974,
    
    -- Maldraxxus
    ["In Death We Are Truly Tested"] = 59011,
    ["The Door to the Unknown"] = 60737,
    ["Words of the Primus"] = 59206,
    
    -- Oribos
    ["Request of the Highlord"] = 61715,
    ["A Glimpse into Darkness"] = 61716,
    ["Journey to Ardenweald"] = 60338,
    
    -- Ardenweald
    ["I Moustache You to Lend a Hand"] = 60763,
    ["First on the Agenda"] = 60341,
    ["Wildseed Rescue"] = 60778,
    ["We Can't Save Them All"] = 60857,
    ["Souls of the Forest"] = 60859,
    ["Keep to the Path"] = 57787,
    ["Spirits of the Glen"] = 57947,
    ["Dreamweaver"] = 57816,
    ["They Need to Calm Down"] = 57949,
    ["Nothing Left to Give"] = 57948,
    ["Mizik the Haughty"] = 57950,
    ["Souls Come Home"] = 57951,
    ["Shooing Wildlife"] = 60567,
    ["Tending to Wildseeds"] = 60563,
    ["Belly Full of Fae"] = 60575,
    ["Hungry for Animacones"] = 60577,
    ["One Special Spirit"] = 60594,
    ["Preparing for the Winter Queen"] = 60600,
    ["Ride to Heartwood Grove"] = 60624,
    ["The End of Former Friends"] = 60637,
    ["Recovering Wildseeds"] = 60638,
    ["Heart of the Grove"] = 60639,
    ["Recovering the Animacones"] = 60647,
    ["Survivors of Heartwood Grove"] = 60648,
    ["The Sacrifices We Must Make"] = 60671,
    ["Recovering the Heart"] = 60709,
    ["Heartless"] = 60724,
    ["Audience with the Winter Queen"] = 60519,
    ["Call of the Hunt"] = 60521,
    ["The Missing Hunters"] = 60628,
    ["Extreme Recycling"] = 60629,
    ["Totem Eclipse"] = 60630,
    ["Big Problem, Little Vorkai"] = 60631,
    ["I Know Your Face"] = 60632,
    ["Return to Tirna Vaal"] = 60522,
    ["Nightmares Manifest"] = 60520,
    ["The Way to Hibernal Hollow"] = 60738,
    ["Soothing Song"] = 60764,
    ["Remnants of the Wild Hunt"] = 60839,
    ["Toppling the Brute"] = 60856,
    ["Ride of the Wild Hunt"] = 60881,
    ["Passage to Hibernal Hollow"] = 60901,
    ["Infusing the Wildseed"] = 60905,
    ["Echoes of Tirna Noch"] = 58473,
    ["Take What You Can"] = 58484,
    ["Read the Roots"] = 58480,
    ["Mementos"] = 58483,
    ["He's Drust in the Way"] = 58486,
    ["Go for the Heart"] = 58488,
    ["Sparkles Rain from Above"] = 58524,
    ["For the Sake of Spirit"] = 60572,
    ["Despoilers"] = 58591,
    ["The Restless Dreamer"] = 58589,
    ["Caring for the Caretakers"] = 58592,
    ["Visions of the Dreamer: Origins"] = 58590,
    ["Visions of the Dreamer: The Betrayal"] = 60578,
    ["End of the Dream"] = 58593,
    ["The Forest Has Eyes"] = 58714,
    ["The Droman's Call"] = 58719,
    ["Missing!"] = 58720,
    ["Enemies at the Gates"] = 60621,
    ["Battle for Hibernal Hollow"] = 58869,
    ["Dying Dreams"] = 60661,
    ["Awaken the Dreamer"] = 58721,
    ["The Court of Winter"] = 58723,
    ["The Queen's Request"] = 58724,
    
    --Oribos
    ["A Plea to Revendreth"] = 57025,
    
    -- Revendreth
    ["The Sinstone"] = 57026,
    ["Invitation of the Master"] = 57007,
    ["Bottom Feeders"] = 56829,
    ["The Greatest Duelist"] = 57381,
    ["The Endmire"] = 60480,  -- optional
    ["On The Road Again"] = 56942,
    ["Rebels on the Road"] = 56955,
    ["Anima Attrition"] = 58433,
    ["To Darkhaven"] = 56978,
    ["The Stoneborn"] = 57174,
    ["A Plea to the Harvesters"] = 58654,
    ["The Master Awaits"] = 57178,
    ["And Then There Were None"] = 60178,  -- optional
    ["The Authority of Revendreth"] = 57179,
    ["I Don't Get My Hands Dirty"] = 57161,
    ["The Accuser's Sinstone"] = 57173,
    ["Inquisitor Stelia's Sinstone"] = 58931,
    ["Temel, the Sin Herald"] = 58932,
    ["It Used to Be Quiet Here"] = 60487,  -- optional
    ["Herald Their Demise"] = 59021,
    ["Inquisitor Vilhelm's Sinstone"] = 57175,
    ["Ending the Inquisitor"] = 59023,
    ["Sinstone Delivery"] = 57176,
    ["The Accuser's Secret"] = 57180,
    ["The Accuser's Fate"] = 57182,
    ["A Lesson in Humility"] = 59232,
    ["The Grove of Terror"] = 57098,
    ["Dread Priming"] = 58916,
    ["Alpha Bat"] = 58941,
    ["King of the Hill"] = 59014,
    ["Let the Hunt Begin"] = 57131,
    ["The Penitent Hunt"] = 57136,
    ["Devour This"] = 57164,
    ["The Accuser"] = 60506,
    ["A Reflection of Truth"] = 57159,
    ["Dredhollow"] = 60313,
    ["Breaking the Hopebreakers"] = 57189,
    ["They Won't Know What Hit Them"] = 57190,
    ["Rebel Reinforcements"] = 59209,
    ["The Fearstalker"] = 59256,
    ["Where is Prince Renathal?"] = 57240,
    ["Sign Your Own Death Warrant"] = 57380,
    ["Chasing Madness"] = 57405,
    ["My Terrible Morning"] = 57426,
    ["Theotar's Mission"] = 57428,
    ["Unbearable Light"] = 57427,
    ["Lost in the Desiccation"] = 57442,
    ["Parasol Components"] = 62189,  -- optional
    ["Tubbins's Tea"] = 57460,
    ["An Uneventful Stroll"] = 57461,
    ["Into the Light"] = 60566,
    ["Securing Sinfall"] = 57724,
    ["In the Ruin of Rebellion"] = 59327,
    ["Prince Renathal"] = 57689,
    ["Cages For All Occasions"] = 57690,
    ["A Royal Key"] = 57691,
    ["Torghast, Tower of the Damned"] = 57693,
    ["Refuge of Revendreth"] = 57694,
    ["Blinded By The Light"] = 59644,
    ["The Master of Lies"] = 58086,
    
    
    
    -- Optional quests
    -- Bastion
    ["The Old Ways"] = 60466,
    ["A Gift for An Acolyte"] = 62714,
    ["More Than A Gift"] = 62715,
    ["WANTED: Altered Sentinel"] = 60316,
    ["An Inspired Moral Inventory"] = 57444,
    ["WANTED: Darkwing"] = 60366,
    ["WANTED: Gorgebeak"] = 60315,
    ["A Fine Journey"] = 59554,
    ["Necrotic Wake: A Paragon's Plight"] = 60057,
    ["In Agthia's Memory"] = 57549,
    ["Agthia's Path"] = 57551,
    ["Warriors of the Void"] = 57552,
    ["Wicked Gateways"] = 57554,
    ["On Wounded Wings"] = 57553,
    ["Shadow's Fall"] = 57555,
    ["Suggested Reading"] = 57712,
    ["Hero's Rest"] = 62718,
    ["Garden in Turmoil"] = 57529,
    ["Disturbing the Peace"] = 57538,
    ["Distractions for Kala"] = 57545,
    ["A Test of Courage"] = 57547,
    ["A Friendly Rivalry"] = 59674,
    ["Tough Love"] = 57568,
    ["Phalynx Malfunction"] = 57931,
    ["Resource Drain"] = 57932,
    
    -- Maldraxxus
    ["Read Between the Lines"] = 58619,
    ["Repeat After Me"] = 58621,
    ["Slaylines"] = 58620,
    ["Secrets Among the Shelves"] = 58622,
    ["Archival Protection"] = 60900,
    ["Trust Fall"] = 59994,
    ["A Complete Set"] = 58623,
    ["Bet On Yourself"] = 59827,
    ["Kill Them Of Course"] = 59917,
    ["...Even The Most Ridiculous Request!"] = 58068,
    ["Juicing Up"] = 58088,
    ["Side Effects"] = 58090,
    ["How To Get A Head"] = 59750,
    ["The Last Guy"] = 59781,
    ["Stuff We All Get"] = 58575,
    ["Team Spirit"] = 59800,
    ["Test Your Mettle"] = 58947,
    ["This Thing Of Ours"] = 59879,
    ["Leave Me a Loan"] = 59203,
    ["Working For The Living"] = 59837,
    ["A Sure Bet"] = 58900,
    ["The Ladder"] = 57316,  -- currently broken
    ["A Plague On Your House"] = 59430,
    ["Pool of Potions"] = 58431,
    ["Callous Concoctions"] = 57301,
    ["Plaguefall: Knee Deep In It"] = 59520,
    ["I Could Be A Contender"] = 62785,
    
    -- Ardenweald
    ["In Need of Gorm Gris"] = 57952,
    ["Forest Disappearances"] = 58161,
    ["Cult of Personality"] = 58164,
    ["Mysterious Masks"] = 58162,
    ["A Desperate Solution"] = 58163,
    ["The Crumbling Village"] = 59802,
    ["Cut the Roots"] = 58165,
    ["Take the Power"] = 59801,
    ["Swollen Anima Seed"] = 62186,
    ["Unknown Assailants"] = 58166,
    ["Nothing Goes to Waste"] = 57818,
    ["Collection Day"] = 57824,
    ["Delivery for Guardian Kota"] = 57825,
    ["The Absent-Minded Artisan"] = 61051,
    ["Finish What He Started"] = 58022,
    ["One Big Problem"] = 58023,
    ["Burrows Away"] = 58024,
    ["Queen of the Underground"] = 58025,
    ["When a Gorm Eats a God"] = 58026,
    ["The Grove of Creation"] = 57660,
    ["Trouble in the Banks"] = 57651,
    ["Breaking A Few Eggs"] = 59621,
    ["Tending to the Tenders"] = 59622,
    ["Supplies Needed: Amber Grease"] = 57652,
    ["Unsafe Workplace"] = 57653,
    ["Supplies Needed: More Husks!"] = 57655,
    ["Gifts of the Forest"] = 57656,
    ["Tied Totem Toter"] = 57657,
    ["Well, Tell the Lady"] = 59656,
    ["Ages-Echoing Wisdom"] = 57865,
    ["Idle Hands"] = 57866,
    ["What a Buzzkill"] = 59623,
    ["The Sweat of Our Brow"] = 57867,  -- currently broken
    ["Craftsman Needs No Tools"] = 57868,
    ["The Games We Play"] = 57870,
    ["Spirit-Gathering Labor"] = 57869,
    ["Outplayed"] = 57871,
    ["Blooming Villains"] = 58265,
    
    -- Revendreth
    ["Not My Job"] = 60509,
    ["It's a Dirty Job"] = 57471,
    ["Dredger Duty"] = 57474,
    ["We're Gonna Need a Bigger Dredger"] = 57477,
    ["Running a Muck"] = 57481,
    ["Words Have Power"] = 58272,
    ["A Curious Invitation"] = 59710,
    ["Bring Out Your Tithe"] = 60176,
    ["Reason for the Treason"] = 60177,
    ["The Lay of the Land"] = 59712,
    ["WANTED: Aggregate of Doom"] = 60277,
    ["Finders-Keepers, Sinners-Weepers"] = 59846,
    ["Active Ingredients"] = 59713,
    ["A Fine Vintage"] = 59714,
    ["Message for Matyas"] = 59715,
    ["Comfortably Numb"] = 59716,
    ["The Field of Honor"] = 59724,
    ["Offer of Freedom"] = 59868,
    ["It's a Trap"] = 59726,
    ["Beast Control"] = 58936,
    ["Hunting Trophies"] = 60514,
    ["WANTED: Enforcer Kristof"] = 60275,
    ["WANTED: Summoner Marcelis"] = 60276,
    ["An Abuse of Power"] = 57919,
    ["The Proper Souls"] = 57920,
    ["The Proper Tools"] = 57921,
    ["The Proper Punishment"] = 57922,
    ["Ritual of Absolution"] = 57923,
    ["Ritual of Judgment"] = 57924,
    ["Archivist Fane"] = 57925,
    ["The Sinstone Archive"] = 57926,
    ["Missing Stone Fiend"] = 60127,
    ["Atonement Crypt Key"] = 57928,
    ["Rebuilding Temel"] = 57927,
    ["Ready to Serve"] = 60128,
    ["Hunting an Inquisitor"] = 57929,
    ["Halls of Atonement: Your Absolution"] = 58092,
}

addonTable.dialogWhitelist = {
    ["A Chilling Summons"] = {
        ["npc"] = "Nazgrim",
        ["dialog"] = "Tell me what happened."
    },
    ["A Moment's Respite"] = {
        ["npc"] = "Lady Jaina Proudmoore",
        ["dialog"] = {
            "Tell me about this place.",
            "Tell me more of the Jailer.",
            "What about the others who were taken?"
        }
    },
    ["The Lion's Cage"] = {
        ["npc"] = "Lady Jaina Proudmoore",
        ["dialog"] = "<Lie low and observe.>"
    },
    ["From the Mouths of Madness"] = {
        ["npc"] = "Highlord Darion Mograine",
        ["dialog"] = "Make it talk."
    },
    ["The Path to Salvation"] = {
        ["npc"] = "Lady Jaina Proudmoore",
        ["dialog"] = "I am ready."
    },
    ["Stranger in an Even Stranger Land"] = {
        ["npc"] = {
            "Protector Captain",
            "Overseer Kah-Delen"
        },
        ["dialog"] = {
            "Where am I? Have I escaped the Maw?",
            "Are you in charge here? Where am I?"
        }
    },
    ["No Place for the Living"] = {
        ["npc"] = "Overseer Kah-Delen",
        ["dialog"] = "Yes, I escaped the Maw."
    },
    ["Audience with the Arbiter"] = {
        ["npc"] = "Tal-Inara",
        ["dialog"] = {
            "I will join you.",
            "What is this place?",
            "I am ready to return."
        }
    },
    ["A Doorway Through the Veil"] = {
        ["npc"] = "Ebon Blade Acolyte",
        ["dialog"] = {
            "Let's head outside.",
            "Summon the portals here."
        }
    },
    ["The Eternal City"] = {
        ["npc"] = {
            "Foreman Au'brak",
            "Caretaker Kah-Rahm",
            "Fatescribe Roh-Tahl",
            "Host Ta'rela",
            "Overseer Ta'readon"
        },
        ["dialog"] = {
            "What is available here?",
            "What is this Hall of Holding?",
            "What is this place?",
            "Thank you for the kind welcome to your Inn.",
            "What is this bazaar?"
        }
    },
    ["Understanding the Shadowlands"] = {
        ["npc"] = {
            "Tal-Inara",
            "Overseer Kah-Sher"
        },
        ["dialog"] = {
            "Can you help us find answers?",
            "I will go with you."
        }
    },
     ["Seek the Ascended"] = {
        ["npc"] = "Pathscribe Roh-Avonavi",
        ["dialog"] = "I am ready. Send me to Bastion."
    },
    
    ["Welcome to Eternity"] = {
        ["npc"] = "Kleia",
        ["dialog"] = "Lead on, Kleia."
    },
    ["A Fate Most Noble"] = {
        ["npc"] = "Greeter Mnemis",
        ["dialog"] = {
            "I think there might have been a mistake.",
            "I am not dead.",
            "I come from Azeroth."
        }
    },
    ["Trouble in Paradise"] = {
        ["npc"] = "Kleia",
        ["dialog"] = "<Tell Kleia what you saw in the Maw.>"
    },
    ["The Work of One's Hands"] = {
        ["npc"] = "Sika",
        ["dialog"] = "Show me what to do, Sika."
    },
    ["Assessing Your Stamina"] = {
        ["npc"] = "Sparring Aspirant",
        ["dialog"] = {
            "Will you spar with me?",
            "I would like to challenge both of you to a spar."
        }
    },
    ["The First Cleansing"] = {
        ["npc"] = "Kleia",
        ["dialog"] = "I am ready to begin."
    },
    ["The Archon's Answer"] = {
        ["npc"] = "Kalisthene",
        ["dialog"] = "I wish to speak to the Archon."
    },
    ["A Temple in Need"] = {
        ["npc"] = {
            "Disciple Fotima",
            "Disciple Helene",
            "Disciple Lykaste"
        },
        ["dialog"] = {
            "I will help you.",
            "Tell me how I can help.",
            "Begin the cleansing. I am ready."
        }
    },
    ["On the Edge of a Revelation"] = {
        ["npc"] = "Vulnerable Aspirant",
        ["dialog"] = {
            "We will get through this together!",
            "You can do this. I believe in you.",
            "Trust in your teachings. They have not led you astray before."
        }
    },
    ["A Wayward Disciple?"] = {
        ["npc"] = "Disciple Nikolon",
        ["dialog"] = "Eridia asked me to find you."
    },
    ["Step Back From That Ledge, My Friend"] = {
        ["npc"] = {
            "Eridia",
            "Fallen Disciple Nikolon"
        },
        ["dialog"] = {
            "Yes, Eridia.",
            "Are you well?",
            "What is it? What is wrong?"
        }
    },
    ["The Enemy You Know"] = {
        ["npc"] = "Disciple Kosmas",
        ["dialog"] = "I am ready."
    },
    ["The Hand of Doubt"] = {
        ["npc"] = "Disciple Kosmas",
        ["dialog"] = "I will stand with you."
    },
    ["Purity's Prerogative"] = {
        ["npc"] = "Vesiphone",
        ["dialog"] = "I will fly with you."
    },
    ["What's In a Memory?"] = {
        ["npc"] = "Mikanikos",
        ["dialog"] = "I am ready."
    },
    ["I MADE You!"] = {
        ["npc"] = "Mikanikos",
        ["dialog"] = "I am ready."
    },
    ["The Vault of the Archon"] = {
        ["npc"] = "Mikanikos",
        ["dialog"] = "What do we do now?"
    },
    ["Your Personal Assistant"] = {
        ["npc"] = {
            "Gramilos", "Haka", "Pico", "Isilios", "Dafi",
            "Laratis", "Koukis", "Zenza", "Thima", "Ilapos",
            "Mupu", "Syla", "Abalus", "Tibo", "Farra",
            "Dintos", "Ipa", "Akiris", "Chaermi", "Bumos",
            "Asellia", "Bola", "Korinthe", "Apa", "Minta",
            "Kimos", "Toulis", "Deka"
        },
        ["dialog"] = "I need assistance."
    },
    ["Steward at Work"] = {
        ["npc"] = {
            "Gramilos", "Haka", "Pico", "Isilios", "Dafi",
            "Laratis", "Koukis", "Zenza", "Thima", "Ilapos",
            "Mupu", "Syla", "Abalus", "Tibo", "Farra",
            "Dintos", "Ipa", "Akiris", "Chaermi", "Bumos",
            "Asellia", "Bola", "Korinthe", "Apa", "Minta",
            "Kimos", "Toulis", "Deka"
        },
        ["dialog"] = "|cFF0000FF(Quest)|r I need you to fix the Beacon of Invocation."
    },
    ["On Swift Wings"] = {
        ["npc"] = "Polemarch Adrestes",
        ["dialog"] = "I am ready to go to Elysian Hold."
    },
    ["Kyrestia, the Firstborne"] = {
        ["npc"] = "Polemarch Adrestes",
        ["dialog"] = "I am ready to speak to the Archon."
    },
    ["Imminent Danger"] = {
        ["npc"] = "Cassius",
        ["dialog"] = "I need to go to the Temple of Courage."
    },
    ["Now or Never"] = {
        ["npc"] = "Thanikos",
        ["dialog"] = "I am with you."
    },
    ["The Final Countdown"] = {
        ["npc"] = "Thanikos",
        ["dialog"] = "I am ready."
    },
    ["A Time for Courage"] = {
        ["npc"] = "Thanikos",
        ["dialog"] = "I am ready."
    },
    ["If You Want Peace..."] = {
        ["npc"] = "Pathscribe Roh-Avonavi",
        ["dialog"] = "I am ready. Send me to Maldraxxus."
    },
    ["The House of the Chosen"] = {
        ["npc"] = "Baroness Draka",
        ["dialog"] = "Tell me your story."
    },
    ["The First Act of War"] = {
        ["npc"] = "Baron Vyraz",
        ["dialog"] = "Reporting for duty. I'm to prepare for war against the other houses."
    },
    ["The Hills Have Eyes"] = {
        ["npc"] = "Chosen Protector",
        ["dialog"] = "You're acting suspicious."
    },
    ["Maintaining Order"] = {
        ["npc"] = {
            "Head Summoner Perex",
            "Drill Sergeant Telice",
            "Secutor Mevix"
        },
        ["dialog"] = "I have orders from Baron Vyraz."
    },
    ["Forging a Champion"] = {
        ["npc"] = "Bonesmith Heirmir",
        ["dialog"] = "What do you know about this blade?"
    },
    ["The Blade of the Primus"] = {
        ["npc"] = "Bonesmith Heirmir",
        ["dialog"] = "I am ready to start forging a rune weapon."
    },
    ["The Seat of the Primus"] = {
        ["npc"] = "Baroness Draka",
        ["dialog"] = "I'm ready. Let's fly to the Seat of the Primus."
    },
    ["A Common Peril"] = {
        ["npc"] = "Baroness Vashj",
        ["dialog"] = "I have a summons from Draka."
    },
    ["Breaking Down Barriers"] = {
        ["npc"] = {
            "Aspirant Thales",
            "Salvaged Praetor",
        },
        ["dialog"] = {
            "How would you breach the barrier?",
            "I need you to follow my directions."
        },
    },
    ["War is Deception"] = {
        ["npc"] = "Baroness Vashj",
        ["dialog"] = "I'm ready. Begin the ritual."
    },
    ["Delving Deeper"] = {
        ["npc"] = "Ve'nari",
        ["dialog"] = "Let's go."
    },
    ["In Death We Are Truly Tested"] = {
        ["npc"] = "Alexandros Mograine",
        ["dialog"] = "I am ready."
    },
    ["I Moustache You to Lend a Hand"] = {
        ["npc"] = {
            "Featherlight",
            "Lady Moonberry"
        },
        ["dialog"] = {
            "I have the lily.",
            "Will you help me gain an audience with the Queen?"
        }
    },
    ["Wildseed Rescue"] = {
        ["npc"] = {
            "Korenth",
            "Featherlight"
        },
        ["dialog"] = {
            "I'm standing in for Lady Moonberry. What happened?",
            "What's a wildseed?",
            "I'll help you.",
            "<Hold still?>"
        }
    },
    ["Souls of the Forest"] = {
        ["npc"] = "Wagonmaster Derawyn",
        ["dialog"] = {
            "I will help you.",
            "You're welcome."
        }
    },
    ["Keep to the Path"] = {
        ["npc"] = {
            "Nelwyn",
            "\"Granny\"",
            "Lady Moonberry"
        },
        ["dialog"] ={
            "I'm going that way, too. I'll help.",
            "My, what big teeth you have Granny.",
            "Hey! What's the big idea?",
            "<Express your appreciation for her help.>"
        }
    },
    ["Nothing Left to Give"] = {
        ["npc"] = {
            "Slanknen",
            "Awool",
            "Rury"
        },
        ["dialog"] = {
            "Let's get you out of here.",
            "It's fine, you can leave with me now.",
            "The fuss is, it's time to leave."
        }
    },
    ["One Special Spirit"] = {
        ["npc"] = "Dreamweaver",
        ["dialog"] = "I'll take the animacones and infuse this wildseed with their anima."
    },
    ["Preparing for the Winter Queen"] = {
        ["npc"] = "Lady Moonberry",
        ["dialog"] = "I'm ready to be properly prepared to meet the Winter Queen."
    },
    ["Recovering the Heart"] = {
        ["npc"] = "Te'zan",
        ["dialog"] = "I need you to use some of your anima to destroy the droman's barrier."
    },
    ["Audience with the Winter Queen"] = {
        ["npc"] = "Lady Moonberry",
        ["dialog"] = {
            "I'm ready to meet the Winter Queen.",
            "Where do I go now?"
        }
    },
    ["The Missing Hunters"] = {
        ["npc"] = "Ara'lon",
        ["dialog"] = "Hunt-Captain Korayn says to report back to the grove."
    },
    ["I Know Your Face"] = {
        ["npc"] = "Hunt-Captain Korayn",
        ["dialog"] = "Who was that? What now?"
    },
    ["The Way to Hibernal Hollow"] = {
        ["npc"] = "Niya",
        ["dialog"] = "I'm taking the wildseed responsible for this to Hibernal Hollow. I could use your help bringing it there."
    },
    ["Soothing Song"] = {
        ["npc"] = "Dreamweaver",
        ["dialog"] = "I'm ready to take this wildseed to Hibernal Hollow."
    },
    ["Passage to Hibernal Hollow"] = {
        ["npc"] = "Ara'lon",
        ["dialog"] = "I'm ready to travel to the Hibernal Hollow."
    },
    ["Infusing the Wildseed"] = {
        ["npc"] = {
            "Proglo",
            "Dreamweaver"
        },
        ["dialog"] = {
            "Droman Aliothe said you were storing anima that we could use to help a wildseed.",
            "Thank you Proglo. I'll use this anima to help the wildseed.",
            "I'm ready to perform the ritual on the wildseed."
        }
    },
    ["Echoes of Tirna Noch"] = {
        ["npc"] = "Ara'lon",
        ["dialog"] = "<Listen to the tale of Tirna Noch.>"
    },
    ["Sparkles Rain from Above"] = {
        ["npc"] = "Lady Moonberry",
        ["dialog"] = "I'm ready to borrow some wings and rain sparkly terror."
    },
    ["Visions of the Dreamer: Origins"] = {
        ["npc"] = "Dreamer's Vision",
        ["dialog"] = "<Go back to the Dreamer's beginning.>"
    },
    ["Visions of the Dreamer: The Betrayal"] = {
        ["npc"] = "Dreamer's Vision",
        ["dialog"] = "<Face the Dreamer's great enemy in battle.>"
    },
    ["End of the Dream"] = {
        ["npc"] = "Dreamweaver",
        ["dialog"] = "|cFF0000FF(Quest)|r I am ready to relive the Dreamer's nightmare."
    },
    ["Battle for Hibernal Hollow"] = {
        ["npc"] = "Droman Aliothe",
        ["dialog"] = "I am ready to stand with you!"
    },
    ["Dying Dreams"] = {
        ["npc"] = "Lady Moonberry",
        ["dialog"] = "I am ready to go."
    },
    ["The Court of Winter"] = {
        ["npc"] = "Winter Queen",
        ["dialog"] = {
            "<Deliver the Primus's Message.>",
            "Yes, your majesty?"
        }
    },
    ["Bottom Feeders"] = {
        ["npc"] = "Lord Chamberlain",
        ["dialog"] = "Come with me."
    },
    ["To Darkhaven"] = {
        ["npc"] = "Lord Chamberlain",
        ["dialog"] = "Ready."
    },
    ["Bring Out Your Tithe"] = {
        ["npc"] = "Darkhaven Villager",
        ["dialog"] = "<Request tithe>"
    },
    ["Reason for the Treason"] = {
        ["npc"] = {
            "Globknob",
            "Courier Rokalai",
            "Soul of Keltesh",
            "Bela"
        },
        ["dialog"] = "|cFF0000FF(Quest)|r <Ask about suspicious activity>"
    },
    ["And Then There Were None"] = {
        ["npc"] = {
            "Ilka",
            "Samu"
        },
        ["dialog"] = "<Present Lajos' invitation>"
    },
    ["The Accuser's Secret"] = {
        ["npc"] = "Lord Chamberlain",
        ["dialog"] = "I'm ready to witness your ascension."
    },
    ["A Lesson in Humility"] = {
        ["npc"] = "Sire Denathrius",
        ["dialog"] = "I will witness the Accuser's judgment."
    },
    ["Dread Priming"] = {
        ["npc"] = "Sinreader Nicola",
        ["dialog"] = "Read this soul their sins."
    },
    ["The Penitent Hunt"] = {
        ["npc"] = "The Fearstalker",
        ["dialog"] = "Let's begin."
    },
    ["The Accuser"] = {
        ["npc"] = "The Accuser",
        ["dialog"] = "Show me."
    },
    ["A Reflection of Truth"] = {
        ["npc"] = "The Accuser",
        ["dialog"] = "I am ready."
    },
    ["The Fearstalker"] = {
        ["npc"] = "The Accuser",
        ["dialog"] = "I am ready."
    },
    ["Sign Your Own Death Warrant"] = {
        ["npc"] = "Venthyr Writing Desk",
        ["dialog"] = {
            "<Forge your Letter of Condemnation.>",
            "Greetings Stonehead,",
            "<Write your real name.>",
            "Insulting the Master",
            "As long as it pleases the Master",
            "Sincerely,\r\nThe Master"
        }
    },
    ["Tubbins's Tea"] = {
        ["npc"] = "Tubbins",
        ["dialog"] = "I'll help you make the tea for Theotar."
    },
    ["An Uneventful Stroll"] = {
        ["npc"] = "Theotar",
        ["dialog"] = "I'm ready. Lead me to the sanctuary."
    },
    ["The Master of Lies"] = {
        ["npc"] = {
            "Projection of Prince Renathal",
            "Prince Renathal"
        },
        ["dialog"] = {
            "Begin the assault. (Queue for Scenario.)",
            "Ready to face the Master."
        }
    },
    
    -- Optional
    ["Suggested Reading"] = {
        ["npc"] = {
            "Aspirant Leda",
            "Aspirant Ikaran"
        },
        ["dialog"] = {
            "Do you have \"Worlds Beyond Counting?\"",
            "Do you have \"The Infinite Treatises?\""
        }
    },
    ["Read Between the Lines"] = {
        ["npc"] = "Ta'eran",
        ["dialog"] = "Tell me about this opportunity."
    },
    ["...Even The Most Ridiculous Request!"] = {
        ["npc"] = {
            "Gunn Gorgebone",
            "Scrapper Minoire",
            "Rencissa the Dynamo"
        },
        ["dialog"] = {
            "Is there anything you need?",
            "Here--this is the biggest rock I could find."
        }
    },
    ["Side Effects"] = {
        ["npc"] = "Scrapper Minoire",
        ["dialog"] = "Here's the enhancers you wanted."
    },
    ["How To Get A Head"] = {
        ["npc"] = "Marcel Mullby",
        ["dialog"] = "I have some bloodtusk skulls for you."
    },
    ["Test Your Mettle"] = {
        ["npc"] = {
            "Valuator Malus",
            "Tester Sahaari"
        },
        ["dialog"] = "Very well. Let us fight."
    },
    ["Leave Me a Loan"] = {
        ["npc"] = "Arena Spectator",
        ["dialog"] = "Ad'narim claims you owe her anima."
    },
    ["A Plague On Your House"] = {
        ["npc"] = {
            "Vial Master Lurgy",
            "Foul-Tongue Cyrlix",
            "Boil Master Yetch"
        },
        ["dialog"] = {
            "Is there any way I can help?",
            "O.K."
        }
    },
    ["Ages-Echoing Wisdom"] = {
        ["npc"] = {
            "Elder Finnan",
            "Elder Gwenna",
            "Groonoomcrooek"
        },
        ["dialog"] = "The Lady of the Falls wanted to make sure you were safe."
    },
    ["A Curious Invitation"] = {
        ["npc"] = "Courier Araak",
        ["dialog"] = "Dimwiddle sent me."
    },
    ["Finders-Keepers, Sinners-Weepers"] = {
        ["npc"] = {
            "Cobwobble",
            "Dobwobble",
            "Slobwobble"
        },
            
        ["dialog"] = {
            "What are you all doing?",
            "Why are the ones with scribbles interesting?",
            "Where does the Taskmaster keep the sinstones?"
        }
    },
    ["Message for Matyas"] = {
        ["npc"] = "Courier Araak",
        ["dialog"] = "We are ready. Please tell the Taskmaster the Maw Walker is here."
    },
    ["Ritual of Absolution"] = {
        ["npc"] = "The Accuser",
        ["dialog"] = "I'm ready. Begin the ritual."
    },
    ["Ritual of Judgment"] = {
        ["npc"] = "The Accuser",
        ["dialog"] = "I'm ready. Begin the ritual."
    }
}