-- Variables
local tiles = {}
local bombs = {}
local text = {}
local flags = {}

local numflags = 0

local gridsize = 15

local hasclicked = false

local currentbombs = 0
local maxbombs = math.floor((gridsize * gridsize) / 3)

local gameover = false
-- Setup
for x=1, gridsize do
  tiles[x] = {}
  flags[x] = {}
  text[x] = {}
  for y=1, gridsize do
    tiles[x][y] = false
  end
end

-- Drawing
function love.draw()
  if tiles == nil then
    -- game over
    if gameover then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("Game over! You hit a bomb!", 50, 50)
    else
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print("Good job! You won!", 50, 50)
    end
  else
    for x=1, gridsize do
      for y=1, gridsize do
        if tiles[x][y] == nil then return end

        if tiles[x][y] == false then
          -- Undiscovered
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.rectangle("fill", x*30, y*30, 25, 25)

          if flags[x] ~= nil then
            if flags[x][y] ~= nil then
              love.graphics.setColor(1, 0, 0, 1)
              love.graphics.print("F", x*30 + 8, y*30 + 5)
            else
              if text[x] ~= nil then
                if text[x][y] ~= nil then
                  love.graphics.setColor(0, 0, 0, 1)
                  love.graphics.print(text[x][y], x*30 + 8, y*30 + 5)
                end
              end
            end
          else
            if text[x] ~= nil then
              if text[x][y] ~= nil then
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.print(text[x][y], x*30 + 8, y*30 + 5)
              end
            end
          end


        else
          love.graphics.setColor(.7, .7, .7, 1)
          love.graphics.rectangle("fill", x*30, y*30, 25, 25)
        end
      end
    end
  end
end

-- Game functions
local function uncover(tx, ty)
  local isbomb = false
  for _,v in pairs(bombs) do
    local xpos = v.xp
    local ypos = v.yp
    if xpos == tx and ypos == ty then
      -- Tile is a bomb
      isbomb = true
      break
    end
  end

  if not isbomb then
    tiles[tx][ty] = true
  else
    tiles = nil
    gameover = true
    return
  end


  local surroundingtiles = {}

  for x=tx-1, tx+1 do
    for y=ty-1, ty+1 do
      if tiles[x] ~= nil then
        if tiles[x][y] ~= nil then
          if tiles[x][y] ~= tiles[tx][ty] and tiles[x][y] ~= true then
            table.insert(surroundingtiles, {xpos = x, ypos = y})
          end
        end
      end
    end
  end

  for _,v in pairs(surroundingtiles) do
    local x = v.xpos
    local y = v.ypos

    if text[x] == nil then text[x] = {} end
    --text[x][y] = 1

    local bombnum = 0

    for px=x-1, x+1 do
      for py=y-1, y+1 do
        if tiles[px] ~= nil then
          if tiles[px][py] ~= nil then


            for _,v in pairs(bombs) do
              local bxpos = v.xp
              local bypos = v.yp

              if px == bxpos and py == bypos then
                bombnum = bombnum + 1
              end
            end


          end
        end
      end
    end

    text[x][y] = bombnum
  end
end

local function processclick(tilex, tiley, clicktype)
  if clicktype == 1 then
    if not hasclicked then
      hasclicked = true

      local existingTiles = tiles
      existingTiles[tilex][tiley] = nil

      for xkey,v in pairs(existingTiles) do
        for ykey,_ in pairs(v) do
          local isb = math.random(0, 10)
          if isb <= 2 and currentbombs < maxbombs then
            currentbombs = currentbombs + 1
            table.insert(bombs, {xp = xkey, yp = ykey})
          end
        end
      end

      uncover(tilex, tiley)
    else
      uncover(tilex, tiley)
    end
  else
    if hasclicked then
      if flags[tilex][tiley] ~= nil then
        if flags[tilex][tiley] ~= nil then
          -- Tile is already flagged
          flags[tilex][tiley] = nil
          numflags = numflags - 1
        end
      else
        if flags[tilex] == nil then
          flags[tilex] = {}
        end
        flags[tilex][tiley] = true
        numflags = numflags + 1
      end

      local matched = 0

      for _,v in pairs(bombs) do
        local bomb_xkey = v.xp
        local bomb_ykey = v.yp

        for flag_xkey,j in pairs(flags) do
          for flag_ykey,_ in pairs(j) do
            if bomb_xkey == flag_xkey and bomb_ykey == flag_ykey then
              matched = matched + 1
            end
          end
        end
      end

      if matched == currentbombs and numflags == currentbombs then
        tiles = nil
        gameover = false
        return
      end
    end
  end
end

-- Mouse click
function love.mousepressed(x, y, button, isTouch)
  for tx=1, gridsize do
    for ty=1, gridsize do
      local xmin = tx*30
      local xmax = tx*30 + 25

      local ymin = ty*30
      local ymax = ty*30 + 25

      if x >= xmin and x <= xmax and y >= ymin and y <= ymax then
        if button == 1 then
          processclick(tx, ty, 1)
        else
          processclick(tx, ty, 2)
        end
        break
      end
    end
  end
end
