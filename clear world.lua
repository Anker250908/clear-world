local BREAK_DELAY = 200      -- delay antar hit
local MOVE_DELAY = 50        -- delay jalan
local SKIP_TIME = 20000      -- 20 detik skip kalau ga kebreak

-- FIX sleep (WAJIB ADA)
function sleep(ms)
    if bot and bot.sleep then
        bot.sleep(ms)
        return
    end
    local t = os.clock()
    while (os.clock() - t) * 1000 < ms do end
end

-- ambil world
function getWorld()
    local ok, world = pcall(function()
        return bot.get_world()
    end)
    if ok then return world end
    return nil
end

-- cek block bisa dibreak
function isBreakable(x, y)
    local tile = bot.tile(x, y)
    if not tile then return false end

    -- fg = foreground block
    if tile.fg ~= 0 then
        return true
    end

    return false
end

-- break 1 block dengan timeout
function breakBlock(x, y)
    local start = os.clock()

    while true do
        local tile = bot.tile(x, y)

        -- kalau sudah kosong → selesai
        if not tile or tile.fg == 0 then
            return true
        end

        -- kalau lebih dari 20 detik → skip
        if (os.clock() - start) * 1000 > SKIP_TIME then
            log("Skip block: " .. x .. "," .. y)
            return false
        end

        bot.break_tile(x, y, "fg")
        sleep(BREAK_DELAY)
    end
end

-- MAIN LOOP
function breakAll()
    while true do
        local world = getWorld()

        if not world or not world.width then
            log("World belum ready...")
            sleep(1000)
        else
            log("Start breaking all blocks...")

            for y = 0, world.height - 1 do
                for x = 0, world.width - 1 do
                    
                    if isBreakable(x, y) then
                        local path = bot.find_path(x, y)

                        if path and path.ok then
                            sleep(MOVE_DELAY)
                            breakBlock(x, y)
                        end
                    end

                end
            end

            log("Semua block sudah dicoba.")
            sleep(3000)
        end
    end
end

breakAll()