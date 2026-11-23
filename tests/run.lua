-- Tests de la logica pura del juego. Corren sin ventana:
--   love . --test            (desde LOVE)
--   lua tests/run.lua        (con cualquier Lua 5.1 / LuaJIT)

package.path = "./?.lua;" .. package.path

-- RNG determinista: mismos resultados en cada corrida, sin LOVE.
local function seededRandom(seed)
    return function(low, high)
        seed = (1103515245 * seed + 12345) % 2147483648
        local unit = seed / 2147483648
        if low == nil then return unit end
        if high == nil then return math.floor(unit * low) + 1 end
        return low + math.floor(unit * (high - low + 1))
    end
end

local passed, failed = 0, 0
local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("  ok   " .. name)
    else
        failed = failed + 1
        print("  FAIL " .. name .. ": " .. tostring(err))
    end
end

local tests = {}
for _, file in ipairs({ "tests.test_progression" }) do
    tests[#tests + 1] = require(file)
end

-- archivos de tests opcionales (se agregan en branches posteriores)
for _, file in ipairs({ "tests.test_gameplay", "tests.test_map" }) do
    local ok, module = pcall(require, file)
    if ok then tests[#tests + 1] = module end
end

print("Running tests...")
for _, module in ipairs(tests) do
    module(test, seededRandom)
end
print(("%d passed, %d failed"):format(passed, failed))

return failed == 0
