Token = {}

function Token:CreateAvatar(path)
    local d = self.d
    local r = self.d * 0.5
    local clip = ClippingMask(self, d, d, function()
        love.graphics.circle("fill", r, r, r)
    end)
    self.clip = clip
    clip:SetOrigin(r, r)

    local img = Image(clip, path)
    self.image = img

    local imgW, imgH = img:GetSize()
    local scaleW, scaleH = d / imgW, d / imgH
    img:SetOrigin(imgW * 0.5, imgH * 0.5)
    img:SetScale(math.max(scaleW, scaleH))
    img:SetPosition(r, r)
end

function Token:CreateLabel(label)
    self.label = Text(self, label)
    local s = 0.03
    local w, h = self.label:GetSize()
    self.label:SetOrigin(w * 0.5, h * 0.5)
    self.label:SetScale(s)
    self.label:SetPosition(0, self.d * 0.6)
end

function Token:Init(parent)
    local data = self.data
    Control.Init(self, parent)

    self.dragMouseButton = 1
    self.prevDragMouseX, self.prevDragMouseY = nil, nil

    self.d = data.diameter
    self:SetPosition(unpack(data.position))
    self:CreateAvatar(data.avatar)
    self:CreateLabel(data.name)

    app.updateEventManager:RegisterListener(self)
end

function Token:MousePressed(x, y, button)
    local tx, ty = self:TransformToLocal(x, y)
    local r = self.d * 0.5
    if tx * tx + ty * ty <= r * r then
        if button == self.dragMouseButton then
            local parentX, parentY = self.parent:TransformToLocal(x, y)
            self.prevDragMouseX, self.prevDragMouseY = parentX, parentY
            self:Reattach()
        end
    end
    Control.MousePressed(self, x, y, button)
end

function Token:MouseReleased(x, y, button)
    if button == self.dragMouseButton and self.prevDragMouseX then
        self.prevDragMouseX, self.prevDragMouseY = nil, nil
        self.data.position = {
            self:GetPosition()
        }
        app.connection:SendRequest(app.data, function()
            return {}
        end)
    end
    Control.MouseReleased(self, x, y, button)
end

function Token:MouseMoved(x, y)
    if self.prevDragMouseX then
        local parentX, parentY = self.parent:TransformToLocal(x, y)
        local selfX, selfY = self:GetPosition()
        self:SetPosition(selfX + (parentX - self.prevDragMouseX), selfY + (parentY - self.prevDragMouseY))
        self.prevDragMouseX, self.prevDragMouseY = parentX, parentY
    end
    Control.MouseMoved(self, x, y)
end

function Token:OnUpdate(dt)
    self.total = (self.total or 0) + dt
    self.image:SetRotation(self.total)
end

MakeModelOf(Token, Control)
