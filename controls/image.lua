Image = class("Image", DrawableControl)

function Image:Init(parent, path)
    local drawable = love.graphics.newImage(path)
    DrawableControl.Init(self, parent, drawable)
end
