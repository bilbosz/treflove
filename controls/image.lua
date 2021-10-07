Image = {}

function Image:Init(parent, path)
    local image = love.graphics.newImage(path)
    local w, h = image:getDimensions()
    DrawableControl.Init(self, parent, w, h, function()
        love.graphics.draw(image)
    end)
end

Loader:LoadClass("controls/drawable-control.lua")
MakeClassOf(Image, DrawableControl)