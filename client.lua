local Keys = {
  
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["UP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX                             = nil
local PlayerData                = {}

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
  
end)
function OpenBodySearchMenu(player)

  ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)

    local elements = {}

    local blackMoney = 0

    for i=1, #data.accounts, 1 do
      if data.accounts[i].name == 'black_money' then
        blackMoney = data.accounts[i].money
      end
    end

    table.insert(elements, {
      label          = 'Ta svarta pengar: ' .. blackMoney,
      value          = 'black_money',
      itemType       = 'item_account',
      amount         = blackMoney
    })

    table.insert(elements, {label = '--- Vapen ---', value = nil})

    for i=1, #data.weapons, 1 do
      table.insert(elements, {
        label          = 'Ta vapen: ' .. ESX.GetWeaponLabel(data.weapons[i].name),
        value          = data.weapons[i].name,
        itemType       = 'item_weapon',
        amount         = data.ammo,
      })
    end

    table.insert(elements, {label = '--- Förråd ---', value = nil})

    for i=1, #data.inventory, 1 do
      if data.inventory[i].count > 0 then
        table.insert(elements, {
          label          = 'Ta föremål: ' .. data.inventory[i].count .. ' ' .. data.inventory[i].label,
          value          = data.inventory[i].name,
          itemType       = 'item_standard',
          amount         = data.inventory[i].count,
        })
      end
    end


    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'body_search',
      {
        title    = 'search',
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        local itemType = data.current.itemType
        local itemName = data.current.value
        local amount   = data.current.amount

        if data.current.value ~= nil then

          TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), itemType, itemName, amount)

          OpenBodySearchMenu(player)

        end

      end,
      function(data, menu)
        menu.close()
      end
    )

  end, GetPlayerServerId(player))

end

function openMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'person_menu',
        {
            title    = ' Person Meny',
            elements = {
                {label = 'Mina ID-Handlingar', value = 'id-card'},
                {label = 'Visitera', value = 'body_search'},
                {label = 'Buntband', value = 'handcuff'},
                {label = 'Bär', value = 'drag'},
                {label = 'Ögonbindel', value = 'blindfold'},
                {label = 'Kissa', value = 'pee'},
                {label = 'Bajsa', value = 'poop'},
              }
        },

        function(data, menu)
            if data.current.value == 'id-card' then
                ESX.UI.Menu.Open(
                    'default', GetCurrentResourceName(), 'id_card_menu',
                    {
                        title    = 'ID Meny',
                        elements = {
                            {label = 'Kolla ID Kort', value = 'check'},
                            {label = 'Visa ID Kort för närmaste person', value = 'show'}
                        }
                    },
                    function(data2, menu2)
                        if data2.current.value == 'check' then
                            TriggerServerEvent('jsfour-legitimation:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                        elseif data2.current.value == 'show' then
                            local player, distance = ESX.Game.GetClosestPlayer()

                            if distance ~= -1 and distance <= 3.0 then
                                TriggerServerEvent('jsfour-legitimation:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
                            else
                                ESX.ShowNotification('Ingen i närheten')
                            end
                        end
                    end,
                    function(data2, menu2)
                        menu2.close()
                    end
                )
            elseif data.current.value == 'pee' then
                 TriggerEvent('pee')
            elseif data.current.value == 'poop' then
                 TriggerEvent('poop')
            elseif data.current.value == 'handcuff' then
              local player, distance = ESX.Game.GetClosestPlayer()
                if distance ~= -1 and distance <= 3.0 then
                  TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(player))
                else
                  ESX.ShowNotification('Ingen i närheten')        
               end
           elseif data.current.value == 'drag' then
            local player, distance = ESX.Game.GetClosestPlayer()
              if distance ~= -1 and distance <= 3.0 then
              TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(player))
            else
              ESX.ShowNotification('Ingen i närheten')        
           end


            elseif data.current.value == 'blindfold' then
                    local player, distance = ESX.Game.GetClosestPlayer()        

                    if distance ~= -1 and distance <= 3.0 then
                       ESX.TriggerServerCallback('jsfour-blindfold:itemCheck', function( hasItem )
                          TriggerServerEvent('jsfour-blindfold', GetPlayerServerId(player), hasItem)
                        end)
                    else
                       ESX.ShowNotification('Ingen i närheten')        
                    end    
            elseif data.current.value == 'body_search' then

                local player, distance = ESX.Game.GetClosestPlayer()

                    if distance ~= -1 and distance <= 3.0 then
                    if IsEntityPlayingAnim(GetPlayerPed(player), "random@mugging3", 'handsup_standing_base', 3) or IsPedFatallyInjured(GetPlayerPed(player)) then 
                      OpenBodySearchMenu(player)
                    else
                      ESX.ShowNotification('Spelaren håller inte upp händerna')  
                    end
                    else
                       ESX.ShowNotification('Ingen i närheten')        
                    end    
              end
        end,
        function(data, menu)
            menu.close()
        end
    )
end


Citizen.CreateThread(function()
  while true do
    Wait(10)
    if IsControlPressed(0, 166) then
        openMenu()
    end
  end
  end)

-- Handcuff
Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 30,  true) -- MoveLeftRight
      DisableControlAction(0, 31,  true) -- MoveUpDown
    end
  end
end)