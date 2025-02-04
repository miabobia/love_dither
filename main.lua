
function getConvValue(y, x)
  convMatrix = {
    { 0/16 , 0/16, 7/16},
    { 1/16 , 5/16, 3/16},
  }
  return convMatrix[y+1][x+1]  
end

function ditherMap(x,y, r,g,b,a)
    max = 1
    min = 0

    -- current pixel value + error
    errorR = error_table[y+1][x+1]["r"]
    errorG = error_table[y+1][x+1]["g"]
    errorB = error_table[y+1][x+1]["b"]
    r = errorR + r
    g = errorG + g
    b = errorB + b

    local rDiffuse = 0
    local gDiffuse = 0
    local bDiffuse = 0
    
    if r >= max then
        -- if r is greater than 1, then r is now max and we track the remainder into errorR
        rDiffuse = max - r
        r = max
    elseif r < min then
        -- if r is less than 0 then r is now min and we track the remainder into errorR
        rDiffuse = -1 * r
        r = min
    else
        if (r <= max/2) then
            rDiffuse = r
        else
            rDiffuse = -1 * (max - r)
        end
    end
    
    if g >= max then
        -- if r is greater than 1, then r is now max and we track the remainder into errorR
        gDiffuse = max - g
        g = max
    elseif g < min then
        -- if r is less than 0 then r is now min and we track the remainder into errorR
        gDiffuse = -1 * g
        g = min
    else
        if (g <= max/2) then
            gDiffuse = g
        else
            gDiffuse = -1 * (max - g)
        end
    end

    if b >= max then
      -- if r is greater than 1, then r is now max and we track the remainder into errorR
      bDiffuse = max - b
      -- error_table[diffuseY][diffuseX]["r"] = max - r        
      b = max
  elseif b < min then
      -- if r is less than 0 then r is now min and we track the remainder into errorR
      bDiffuse = -1 * b
      -- error_table[diffuseY][diffuseX]["r"] = -1 * r
      b = min
  else
      if (b <= max/2) then
          bDiffuse = b
          -- error_table[diffuseY][diffuseX]["r"] = r
      else
          bDiffuse = -1 * (max - b)
          -- error_table[diffuseY][diffuseX]["r"] = -1 * (max - r)
      end
  end
  
  -- distribute our errors to places
    diffuseX = x + 1
    diffuseY = y + 1

    error_table[diffuseY + 0][diffuseX+2]["r"] = error_table[diffuseY + 0][diffuseX+2]["r"] + rDiffuse * getConvValue(0,2)
    error_table[diffuseY + 1][diffuseX+0]["r"] = error_table[diffuseY + 1][diffuseX+0]["r"] + rDiffuse * getConvValue(1,0)
    error_table[diffuseY + 1][diffuseX+1]["r"] = error_table[diffuseY + 1][diffuseX+1]["r"] + rDiffuse * getConvValue(1,1)
    error_table[diffuseY + 1][diffuseX+2]["r"] = error_table[diffuseY + 1][diffuseX+2]["r"] + rDiffuse * getConvValue(1,2)

    error_table[diffuseY + 0][diffuseX+2]["g"] = error_table[diffuseY + 0][diffuseX+2]["g"] + gDiffuse * getConvValue(0,2)
    error_table[diffuseY + 1][diffuseX+0]["g"] = error_table[diffuseY + 1][diffuseX+0]["g"] + gDiffuse * getConvValue(1,0)
    error_table[diffuseY + 1][diffuseX+1]["g"] = error_table[diffuseY + 1][diffuseX+1]["g"] + gDiffuse * getConvValue(1,1)
    error_table[diffuseY + 1][diffuseX+2]["g"] = error_table[diffuseY + 1][diffuseX+2]["g"] + gDiffuse * getConvValue(1,2)

    error_table[diffuseY + 0][diffuseX+2]["b"] = error_table[diffuseY + 0][diffuseX+2]["b"] + bDiffuse * getConvValue(0,2)
    error_table[diffuseY + 1][diffuseX+0]["b"] = error_table[diffuseY + 1][diffuseX+0]["b"] + bDiffuse * getConvValue(1,0)
    error_table[diffuseY + 1][diffuseX+1]["b"] = error_table[diffuseY + 1][diffuseX+1]["b"] + bDiffuse * getConvValue(1,1)
    error_table[diffuseY + 1][diffuseX+2]["b"] = error_table[diffuseY + 1][diffuseX+2]["b"] + bDiffuse * getConvValue(1,2)

    return r,g,b,1
end

function love.load()
    -- original data on the left
    whaleData = love.image.newImageData('hawse.jpg')
    whale = love.graphics.newImage(whaleData)
    
    love.window.setMode(whaleData:getWidth() * 4, whaleData:getHeight() * 2)
    -- dithered data on the right
    dithered = whaleData:clone()
    
    -- error diffusion table
    error_table = {}
    for i = 1, dithered:getHeight() + 2 do
        error_table[i] = {}
        for j = 1, dithered:getWidth() + 2 do
            error_table[i][j] = {r=0, g=0, b=0, a=0}

        end
    end

    print(#error_table, #error_table[1])
    
    dithered:mapPixel(ditherMap)
    ditheredImage = love.graphics.newImage(dithered)
end

function love.draw()
    love.graphics.draw(whale, 0, 0)
    love.graphics.draw(ditheredImage, 313, 0)
end
