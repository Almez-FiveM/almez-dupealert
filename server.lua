local mysqlString = "SELECT items, stash FROM stashitemsnew";
local mysqlString2 = "SELECT inventory, citizenid, name, steam, firstname, lastname FROM players";
local mysqlString3 = "SELECT items, plate FROM trunkitemsnew";
Series = {}
exports["oxmysql"]:execute(mysqlString2, function(data2)
exports["oxmysql"]:execute(mysqlString, function(data)
exports["oxmysql"]:execute(mysqlString3, function(data3) 
    for k,v in pairs (data2) do
        local inv = json.decode(v.inventory)
        if inv ~= nil then 
            for kk,vv in pairs (inv) do
                if vv.type == "weapon" then
                    table.insert(Series, {
                        info = vv.info.serie,
                        player = v.name,
                        charname = v.firstname .. " " .. v.lastname,
                        cid = v.citizenid,
                        weapon = vv.name,
                        steam = v.steam,
                        type = "Players"
                    })
                end
            end
        end
    end
    for k,v in pairs (data3) do
        local inv = json.decode(v.items)
        if inv ~= nil then
            for kk,vv in pairs (inv) do
                if vv.info ~= nil then
                    if vv.info.serie ~= nil then
                        exports["oxmysql"]:execute("SELECT citizenid FROM owned_vehicles WHERE plate = @plate", {
                            ["@plate"] = v.plate
                        }, function(resplate)
                            if resplate[1] then 
                                local cid = resplate[1].citizenid
                                exports["oxmysql"]:execute("SELECT firstname, lastname, steam, name FROM players WHERE citizenid = @cid",{
                                    ["@cid"] = cid
                                }, function(res)
                                    if res[1] then 
                                        table.insert(Series, {
                                            info = vv.info.serie,
                                            player = "Trunk ".. res[1].name,
                                            charname = res[1].firstname .. " " .. res[1].lastname,
                                            cid = cid,
                                            weapon = vv.name,
                                            steam = res[1].steam,
                                            type = "Trunk"
                                        })
                                    else
                                        table.insert(Series, {
                                            info = vv.info.serie,
                                            player = "Trunk Player Not Found",
                                            charname = v.plate,
                                            cid = v.plate,
                                            weapon = vv.name,
                                            steam = "Trunk Player Not Found",
                                            type = "Trunk"
                                        })
                                    end
                                end)
                            else
                                table.insert(Series, {
                                    info = vv.info.serie,
                                    player = "Trunk Player Not Found",
                                    charname = v.plate,
                                    weapon = vv.name,
                                    cid = v.plate,
                                    steam = "Trunk Player Not Found",
                                    type = "Trunk"
                                })
                            end
                        end)
                    end
                end
            end
        end
    end
    for k,v in pairs (data) do
        local inv = json.decode(v.items)
        if inv ~= nil then
            for kk,vv in pairs (inv) do
                if vv.info ~= nil then
                    if vv.info.serie ~= nil then 
                        local word = Split(v.stash, "_")
                        local cid = tostring(word[2])
                        exports["oxmysql"]:execute("SELECT firstname, lastname, steam, name FROM players WHERE citizenid = @cid",{
                            ["@cid"] = cid
                        }, function(res)
                            if res[1] then 
                                table.insert(Series, {
                                    info = vv.info.serie,
                                    player = "Stash".. res[1].name,
                                    charname = res[1].firstname .. " " .. res[1].lastname,
                                    cid = cid,
                                    weapon = vv.name,
                                    steam = res[1].steam,
                                    type = "Stash"
                                })
                            else
                                table.insert(Series, {
                                    info = vv.info.serie,
                                    player = "Stash",
                                    charname = "Oyuncu Bulunamadı",
                                    cid = cid,
                                    weapon = vv.name,
                                    steam = "Stash",
                                    type = "Trunk",
                                })
                            end
                        end)
                    end
                end
            end
        end
    end
    print("[ALMEZ-DEBUG] Kayıtlar bekleniyor... 3")
    Wait(1000)
    print("[ALMEZ-DEBUG] Kayıtlar bekleniyor... 2")
    Wait(1000)
    print("[ALMEZ-DEBUG] Kayıtlar bekleniyor... 1")
    Wait(1000)
    local Series_uniqueAll = {}
    local Series_dupAll = {}
    for k,v in pairs (Series) do
        if not Series_uniqueAll[v.info] then
            Series_uniqueAll[v.info] = true
        else
            table.insert(Series_dupAll, {
                info = v.info,
                player = v.player,
                charname = v.charname,
                cid = v.cid,
                weapon = v.weapon,
                steam = v.steam,
                type = v.type
            })
        end
    end
    sendToDiscord(Series_dupAll)
    print("[ALMEZ-DEBUG] Kayıtlar discord logu olarak gönderildi.")
end)
end)
end)

Webhook = "https://discord.com/api/webhooks/997547309715959968/_U4saHrCofJkQSx_52RT04-wtiI_7YNEy1Ty3Mku776JleBUi5Df1Pnkf2J7IO57yxKp"
sendToDiscord = function(table)
    local desc = ""
    for k,v in pairs(table) do 
        desc = desc .. "[" .. k .. "-" .. v.type .. "]\nSteam: "..v.steam.."\nCid: "..v.cid.."\nİsim: "..v.charname..'\nSeri No: '..v.info.. "\n Silah: ".. string.upper(v.weapon) .."\n--------------------------\n"
    end
    local embed = {
        {
            ["color"] = 16753920,
            ["title"] = "Duplicate Series Alert",
            ["description"] = desc,
            ["footer"] = {
                ["text"] = "made by Almez",
            },
        }
    }
    PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = "almez log", embeds = embed}), { ['Content-Type'] = 'application/json' })
end
function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end