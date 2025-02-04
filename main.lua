--[[

Floyd-Steinberg Dithering

The first - and arguably most famous - 2D error diffusion formula 
was published by Robert Floyd and Louis Steinberg in 1976. 
It diffuses errors in the following pattern:

       X   7
   3   5   1

     (1/16)

In the notation above, “X” refers to the current pixel. 
The fraction at the bottom represents the divisor for the error. 
Said another way, the Floyd-Steinberg formula could be written as:

           X    7/16
   3/16  5/16   1/16

But that notation is long and messy, so I’ll stick with the original.

To use our original example of converting a pixel of value “96” to 0 (black) or 255 (white), if we force the pixel to black, the resulting error is 96. We then propagate that error to the surrounding pixels by dividing 96 by 16 ( = 6), then multiplying it by the appropriate values, e.g.:

           X     +42
   +18    +30    +6

By spreading the error to multiple pixels, each with a different value, we minimize any distracting bands of speckles like the original error diffusion example.
]] 

-- loops over pixels left to right top to bottom

-- function blackWhiteDither(x,y,r,g,b,a)
--     max = 255
--     sum_of_pixels  = r + g + b
--     if sum_of_pixels > (max / 2) then
--         return 1, 1, 1, 1
--     else 
--         return 0, 0, 0, 1
--     end
-- end
-- function colorRGBMaxorMin(x,y, r,g,b,a)
--     max = 1
--     newR = 0
--     newG = 0
--     newB = 0
--     if r > (max / 2) then newR = 1 else newR = 0 end
--     if g > (max / 2) then newG = 1 else newG = 0 end
--     if b > (max / 2) then newB = 1 else newB = 0 end
--     return newR,newG,newB,1
-- end

-- convMatrix = {
--    {p ={1,  0},  v = 7/16}
--    {p ={-1, 1},  v = 1/16},
--    {p ={0,  1},  v = 5/16},
--    {p ={1,  1}   v = 3/16},
-- }

function getConvValue(y, x)
  convMatrix = {
    { 0/16 , 0/16, 7/16},
    { 1/16 , 5/16, 3/16},
  }
  return convMatrix[y+1][x+1]  
end

function ditherMap(x,y, r,g,b,a)
    -- print("START:", r, g, b, a)
    -- calculate errors
    max = 1
    min = 0

    -- current pixel value + error
    errorR = error_table[y+1][x+1]["r"]
    errorG = error_table[y+1][x+1]["g"]
    errorB = error_table[y+1][x+1]["b"]
    -- print("ERRORS:", errorR, errorG, errorB, a)
    r = errorR + r
    g = errorG + g
    b = errorB + b


    -- if x == dithered:getWidth() and y == dithered:getHeight() then
    --     return 1, 0, 0, 1
    -- end


    local rDiffuse = 0
    local gDiffuse = 0
    local bDiffuse = 0
    
    if r >= max then
        -- if r is greater than 1, then r is now max and we track the remainder into errorR
        rDiffuse = max - r
        -- error_table[diffuseY][diffuseX]["r"] = max - r        
        r = max
    elseif r < min then
        -- if r is less than 0 then r is now min and we track the remainder into errorR
        rDiffuse = -1 * r
        -- error_table[diffuseY][diffuseX]["r"] = -1 * r
        r = min
    else
        if (r <= max/2) then
            rDiffuse = r
            -- error_table[diffuseY][diffuseX]["r"] = r
        else
            rDiffuse = -1 * (max - r)
            -- error_table[diffuseY][diffuseX]["r"] = -1 * (max - r)
        end
    end
    
    if g >= max then
        -- if r is greater than 1, then r is now max and we track the remainder into errorR
        gDiffuse = max - g
        -- error_table[diffuseY][diffuseX]["g"] = max - g
        g = max
    elseif g < min then
        -- if r is less than 0 then r is now min and we track the remainder into errorR
        gDiffuse = -1 * g
        -- error_table[diffuseY][diffuseX]["g"] = -1 * g
        g = min
    else
        if (g <= max/2) then
            gDiffuse = g
            -- eggog_table[diffuseY][diffuseX]["g"] = g
        else
            gDiffuse = -1 * (max - g)
            -- error_table[diffuseY][diffuseX]["r"] = -1 * (max - r)
        end
    end

    -- if b >= max then
    --     -- if r is greater than 1, then r is now max and we track the remainder into errorR
    --     error_table[diffuseY][diffuseX]["b"] = max - b        
    --     b = max
    -- elseif b < min then
    --     -- if r is less than 0 then r is now min and we track the remainder into errorR
    --     error_table[diffuseY][diffuseX]["b"] = -1 * b
    --     b = min
    -- else
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

  -- using convolution matrix diffuse errors


  -- pass on the error
  -- diffuseX = x+2
  -- diffuseY = y+1
  -- -- diffuse errors
  -- if diffuseX % (dithered:getWidth()) == 0 then
  --     diffuseX = 1
  
  --     if diffuseY % dithered:getHeight() ~= 0 then
  --         diffuseY = diffuseY + 1
  --     end
  -- end
  
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
    -- Image height, width = 313,222
    
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