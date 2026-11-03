-- Chinese line breaking and ellipsis in the FRLG font layer.
-- Runs headless with the love stub: the CJK TTF is absent, so the advances
-- come from the fallback table, but the split points are what this checks.

love = require("tests.love_stub")
local F = require("src.ui.game3.frlg_font")

local failures = 0
local function eq(got, want, label)
  if got ~= want then
    failures = failures + 1
    print(("FAIL %s: got [%s] want [%s]"):format(label, tostring(got), tostring(want)))
  end
end
local function ok(cond, label)
  if not cond then failures = failures + 1 print("FAIL " .. label) end
end

-- A space-less Chinese sentence breaks between characters.
local lines = F.breakLine("妙蛙种子是一种四足的宝可梦，外表类似蟾蜍。", 60)
ok(#lines >= 2, "Chinese breaks into multiple lines")
for _, line in ipairs(lines) do
  ok(F.measure(line) <= 60 + 12, "line fits the budget: " .. line)
end

-- Latin still breaks at word boundaries.
local latin = F.breakLine("The quick brown fox jumps over the lazy dog.", 100)
eq(latin[1], "The quick brown", "Latin word wrap keeps whole words")

-- A word wider than the box is split rather than overflowing.
local long = F.breakLine("Supercalifragilisticexpialidocious", 100)
ok(#long > 1, "overlong word is split")
for _, line in ipairs(long) do ok(F.measure(line) <= 100, "split chunk fits") end

-- Closing punctuation never starts a line.
local punct = F.breakLine("宝可梦，外表类似蟾蜍。是的", 60)
for _, line in ipairs(punct) do
  ok(not line:match("^[，。、；：？！）】」』…～]"), "line starts with text: " .. line)
end

-- Brace tags are atomic and do not split.
local tagged = F.breakLine("{PLAYER}你好，世界！这是一个测试。", 60)
ok(#tagged >= 1, "tagged text still breaks")
ok(tagged[1]:find("{PLAYER}", 1, true) ~= nil, "tag stays whole")

-- Ellipsis fits the target width and only appears when needed.
eq(F.ellipsize("皮卡丘", 60), "皮卡丘", "short text untouched")
local cut = F.ellipsize("妙蛙种子是一种四足的宝可梦", 60)
ok(cut:sub(-3) == "…", "long text ends in an ellipsis")
ok(F.measure(cut) <= 60, "ellipsized text fits")

-- wrapClamp caps a panel to its line budget and ellipsizes the last line.
local clamped = F.wrapClamp("我代表楠木馆长对这艘船进行调查，他还让我找一个探测器。", 60, 2)
local n = 0
for _ in clamped:gmatch("\n") do n = n + 1 end
ok(n <= 1, "wrapClamp keeps at most two lines")
ok(clamped:sub(-3) == "…", "wrapClamp ends the last line in an ellipsis")

-- wrap() no longer depends on newlines in the source.
local wrapped = F.wrap("我代表楠木馆长对这艘船进行调查，他还让我找一个探测器。", 100)
ok(wrapped:find("\n") ~= nil, "wrap() inserts line breaks")

if failures == 0 then
  print("game3_zh_wrap_test: ok")
else
  print("game3_zh_wrap_test: " .. failures .. " failure(s)")
  os.exit(1)
end
